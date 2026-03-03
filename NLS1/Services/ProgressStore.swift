//
//  ProgressStore.swift
//  NLS1
//

import Foundation
import SwiftUI
import Combine

final class ProgressStore: ObservableObject {
    static let shared = ProgressStore()

    @AppStorage("onboardingCompleted") var onboardingCompleted: Bool = false
    @AppStorage("selectedDifficulty") var selectedDifficultyRaw: String = Difficulty.beginner.rawValue
    @AppStorage("selectedBackdrop") private var selectedBackdropRaw: String = "default"
    @AppStorage("levelsCompleted") private var levelsCompletedRaw: String = "0"
    @AppStorage("bestAccuracy") private var bestAccuracyRaw: Double = 0
    @AppStorage("longestSurvival") private var longestSurvivalRaw: Double = 0
    @AppStorage("trainingsCompleted") private var trainingsCompletedRaw: String = ""

    private let fileURL: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    struct StoredProgress: Codable {
        var unlockedLevelIds: [Int]
        var levelBestScores: [String: LevelScore]
        var achievementsUnlocked: [String]
        var trainingCompletedIds: [String]

        struct LevelScore: Codable {
            var timeSurvived: Double
            var accuracy: Double
            var cleanDodges: Int
        }

        static let empty = StoredProgress(
            unlockedLevelIds: [1],
            levelBestScores: [:],
            achievementsUnlocked: [],
            trainingCompletedIds: []
        )
    }

    @Published private(set) var stored: StoredProgress

    var selectedDifficulty: Difficulty {
        get { Difficulty(rawValue: selectedDifficultyRaw) ?? .beginner }
        set { selectedDifficultyRaw = newValue.rawValue }
    }

    var selectedBackdrop: String {
        get { selectedBackdropRaw }
        set { selectedBackdropRaw = newValue }
    }

    var levelsCompleted: Int {
        get { Int(levelsCompletedRaw) ?? 0 }
        set { levelsCompletedRaw = String(newValue) }
    }

    var bestAccuracy: Double {
        get { bestAccuracyRaw }
        set { bestAccuracyRaw = max(bestAccuracyRaw, newValue) }
    }

    var longestSurvival: Double {
        get { longestSurvivalRaw }
        set { longestSurvivalRaw = max(longestSurvivalRaw, newValue) }
    }

    var trainingsCompleted: Set<String> {
        get {
            if trainingsCompletedRaw.isEmpty { return [] }
            return Set(trainingsCompletedRaw.split(separator: ",").map { String($0) })
        }
        set {
            trainingsCompletedRaw = newValue.sorted().joined(separator: ",")
            stored.trainingCompletedIds = Array(newValue).sorted()
        }
    }

    init() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        fileURL = docs.appendingPathComponent("progress.json")
        if let data = try? Data(contentsOf: fileURL),
           let decoded = try? decoder.decode(StoredProgress.self, from: data) {
            stored = decoded
        } else {
            stored = .empty
        }
    }

    func save() {
        guard let data = try? encoder.encode(stored) else { return }
        try? data.write(to: fileURL)
    }

    func isLevelUnlocked(_ levelId: Int) -> Bool {
        stored.unlockedLevelIds.contains(levelId)
    }

    func unlockLevel(_ levelId: Int) {
        if !stored.unlockedLevelIds.contains(levelId) {
            stored.unlockedLevelIds.append(levelId)
            stored.unlockedLevelIds.sort()
        }
        levelsCompleted = max(levelsCompleted, stored.unlockedLevelIds.count)
        save()
    }

    func recordLevelResult(levelId: Int, timeSurvived: Double, accuracy: Double, cleanDodges: Int) {
        bestAccuracy = accuracy
        longestSurvival = timeSurvived
        let key = String(levelId)
        var score = stored.levelBestScores[key] ?? .init(timeSurvived: 0, accuracy: 0, cleanDodges: 0)
        score.timeSurvived = max(score.timeSurvived, timeSurvived)
        score.accuracy = max(score.accuracy, accuracy)
        score.cleanDodges = max(score.cleanDodges, cleanDodges)
        stored.levelBestScores[key] = score
        unlockLevel(levelId)
        if levelId < 30 { unlockLevel(levelId + 1) }
        checkAchievementsAfterRun(cleanDodges: cleanDodges, accuracy: accuracy, timeSurvived: timeSurvived)
        checkLevelCompletionAchievements(levelId: levelId)
        save()
    }

    private func checkLevelCompletionAchievements(levelId: Int) {
        if levelId >= 1, !stored.achievementsUnlocked.contains("first_run") {
            stored.achievementsUnlocked.append("first_run")
            objectWillChange.send()
        }
    }

    private func checkAchievementsAfterRun(cleanDodges: Int, accuracy: Double, timeSurvived: Double) {
        var changed = false
        if cleanDodges >= 10, !stored.achievementsUnlocked.contains("clean_run_1") { stored.achievementsUnlocked.append("clean_run_1"); changed = true }
        if cleanDodges >= 25, !stored.achievementsUnlocked.contains("clean_run_2") { stored.achievementsUnlocked.append("clean_run_2"); changed = true }
        if cleanDodges >= 50, !stored.achievementsUnlocked.contains("clean_run_3") { stored.achievementsUnlocked.append("clean_run_3"); changed = true }
        if accuracy >= 85, !stored.achievementsUnlocked.contains("cadence_keeper") { stored.achievementsUnlocked.append("cadence_keeper"); changed = true }
        if timeSurvived >= 60, !stored.achievementsUnlocked.contains("no_hit_streak") { stored.achievementsUnlocked.append("no_hit_streak"); changed = true }
        if changed { objectWillChange.send() }
    }

    func completeTraining(_ moduleId: String) {
        if !stored.trainingCompletedIds.contains(moduleId) {
            stored.trainingCompletedIds.append(moduleId)
        }
        trainingsCompleted = Set(stored.trainingCompletedIds)
        if stored.trainingCompletedIds.count >= 3, !stored.achievementsUnlocked.contains("training_graduate") {
            stored.achievementsUnlocked.append("training_graduate")
            objectWillChange.send()
        }
        save()
    }

    func isTrainingCompleted(_ moduleId: String) -> Bool {
        stored.trainingCompletedIds.contains(moduleId)
    }

    func isAchievementUnlocked(_ id: String) -> Bool {
        stored.achievementsUnlocked.contains(id)
    }

    func achievementsUnlockedCount() -> Int {
        stored.achievementsUnlocked.count
    }

    func resetProgress() {
        onboardingCompleted = false
        selectedBackdropRaw = "default"
        levelsCompletedRaw = "0"
        bestAccuracyRaw = 0
        longestSurvivalRaw = 0
        trainingsCompletedRaw = ""
        stored = .empty
        save()
    }
}
