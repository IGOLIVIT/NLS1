//
//  LevelConfig.swift
//  NLS1
//

import Foundation

struct LevelConfig: Identifiable {
    let id: Int
    let regionName: String
    let goalDescription: String
    let goalType: GoalType
    let targetValue: Double
    let laneCount: Int
    let spawnRate: Double
    let targetSpeed: Double
    let glyphPetalsReward: Int
    let chargeStampsReward: Int

    enum GoalType: String, Codable {
        case surviveSeconds
        case accuracyPercent
        case noHitStreak
    }

    static let regions: [(name: String, levelRange: ClosedRange<Int>)] = [
        ("Root Nebula", 1...6),
        ("Canopy Drift", 7...12),
        ("Pollen Belt", 13...18),
        ("Vine Array", 19...24),
        ("Aurora Orchard", 25...30),
    ]

    static func region(for levelId: Int) -> String {
        regions.first { $0.levelRange.contains(levelId) }?.name ?? "Unknown"
    }

    static func config(for levelId: Int, difficulty: Difficulty) -> LevelConfig {
        let regionName = region(for: levelId)
        let laneCount = difficulty.laneCount
        let (goalType, targetValue, goalDesc): (GoalType, Double, String) = {
            switch (levelId - 1) % 3 {
            case 0:
                let sec = 15.0 + Double(levelId) * 2 + difficulty.survivalBonus
                return (.surviveSeconds, sec, "Survive \(Int(sec)) seconds")
            case 1:
                let pct = 60.0 + Double(min(levelId, 15)) + difficulty.accuracyBonus
                return (.accuracyPercent, pct, "Reach \(Int(pct))% accuracy")
            default:
                let streak = 5 + levelId / 2 + difficulty.streakBonus
                return (.noHitStreak, Double(streak), "No-hit streak of \(streak)")
            }
        }()
        let baseSpeed = 1.2 + Double(levelId) * 0.05
        let baseSpawn = 0.8 + Double(levelId) * 0.03
        return LevelConfig(
            id: levelId,
            regionName: regionName,
            goalDescription: goalDesc,
            goalType: goalType,
            targetValue: targetValue,
            laneCount: laneCount,
            spawnRate: min(baseSpawn + difficulty.spawnBonus, 2.5),
            targetSpeed: min(baseSpeed + difficulty.speedBonus, 3.0),
            glyphPetalsReward: 1 + levelId / 5,
            chargeStampsReward: levelId % 5 == 0 ? 1 : 0
        )
    }
}

enum Difficulty: String, CaseIterable {
    case beginner
    case skilled
    case expert

    var laneCount: Int {
        switch self {
        case .beginner: return 3
        case .skilled: return 4
        case .expert: return 5
        }
    }

    var survivalBonus: Double { switch self { case .beginner: return 0; case .skilled: return 5; case .expert: return -3 } }
    var accuracyBonus: Double { switch self { case .beginner: return 5; case .skilled: return 0; case .expert: return -5 } }
    var streakBonus: Int { switch self { case .beginner: return 2; case .skilled: return 0; case .expert: return -1 } }
    var spawnBonus: Double { switch self { case .beginner: return -0.2; case .skilled: return 0; case .expert: return 0.3 } }
    var speedBonus: Double { switch self { case .beginner: return -0.2; case .skilled: return 0; case .expert: return 0.2 } }
}
