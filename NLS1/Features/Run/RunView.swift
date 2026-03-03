//
//  RunView.swift
//  NLS1
//

import SwiftUI
import SpriteKit

struct RunView: View {
    @EnvironmentObject var progress: ProgressStore
    @Binding var path: [Route]
    let levelId: Int
    var difficulty: Difficulty { progress.selectedDifficulty }
    @State private var gameOver: Bool = false
    @State private var survived: Double = 0
    @State private var accuracy: Double = 0
    @State private var cleanDodges: Int = 0
    @State private var scene: GameScene?

    private var config: LevelConfig {
        LevelConfig.config(for: levelId, difficulty: difficulty)
    }

    var body: some View {
        ZStack {
            CosmicGardenBackground(animated: false)
            if let sc = scene {
                SpriteView(scene: sc)
                    .ignoresSafeArea()
                    .gesture(
                        DragGesture(minimumDistance: 30)
                            .onEnded { value in
                                if value.translation.width < -20 {
                                    sc.swipeLeft()
                                } else if value.translation.width > 20 {
                                    sc.swipeRight()
                                }
                            }
                    )
            }
            if !gameOver {
                levelBadge
            }
            if gameOver {
                runSummaryOverlay
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Exit") {
                    path.removeAll()
                }
                .foregroundColor(Theme.textPrimary)
            }
        }
        .onAppear {
            let sc = GameScene(size: UIScreen.main.bounds.size)
            sc.scaleMode = .resizeFill
            sc.config = config
            sc.onGameOver = { surv, acc, dodges in
                survived = surv
                accuracy = acc
                cleanDodges = dodges
                progress.recordLevelResult(levelId: levelId, timeSurvived: surv, accuracy: acc, cleanDodges: dodges)
                gameOver = true
            }
            scene = sc
        }
    }

    private var levelBadge: some View {
        VStack {
            Text("Level \(levelId)")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(Theme.textPrimary)
                .padding(.horizontal, Theme.spacingM)
                .padding(.vertical, Theme.spacingS)
                .background(Theme.surfaceCard.opacity(0.9))
                .cornerRadius(Theme.cornerRadiusM)
            Spacer()
        }
        .padding(.top, Theme.spacingM)
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private var runSummaryOverlay: some View {
        VStack(spacing: Theme.spacingL) {
            Text("Run Complete")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(Theme.textPrimary)
            VStack(alignment: .leading, spacing: Theme.spacingS) {
                summaryRow("Time survived", String(format: "%.1fs", survived))
                summaryRow("Accuracy", "\(Int(accuracy))%")
                summaryRow("Clean dodges", "\(cleanDodges)")
                HStack {
                    if config.glyphPetalsReward > 0 {
                        Label("\(config.glyphPetalsReward) Glyph Petals", systemImage: "leaf.fill")
                            .font(.caption)
                            .foregroundColor(Theme.electricClover)
                    }
                    if config.chargeStampsReward > 0 {
                        Label("\(config.chargeStampsReward) Charge Stamp", systemImage: "seal.fill")
                            .font(.caption)
                            .foregroundColor(Theme.warmGold)
                    }
                }
            }
            .padding(Theme.spacingL)
            .frame(maxWidth: .infinity)
            .background(Theme.surfaceCard)
            .cornerRadius(Theme.cornerRadiusM)
            PrimaryButton(title: "Replay", action: {
                gameOver = false
                restartScene()
            })
            PrimaryButton(title: "Next Level", action: goToNextLevel)
            SecondaryButton(title: "Home", action: { path.removeAll() })
        }
        .padding(Theme.spacingXL)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.emeraldNight.opacity(0.95))
        .contentShape(Rectangle())
        .allowsHitTesting(true)
    }

    private func summaryRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .foregroundColor(Theme.textSecondary)
            Spacer()
            Text(value)
                .foregroundColor(Theme.textPrimary)
                .fontWeight(.medium)
        }
        .font(.subheadline)
    }

    private func goToNextLevel() {
        if levelId >= 30 {
            path.removeAll()
            return
        }
        let nextId = levelId + 1
        // Two-phase: pop to root, then push next level so NavigationStack updates reliably
        path.removeAll()
        DispatchQueue.main.async {
            path.append(.run(levelId: nextId))
        }
    }

    private func restartScene() {
        gameOver = false
        let sc = GameScene(size: UIScreen.main.bounds.size)
        sc.scaleMode = .resizeFill
        sc.config = config
        sc.onGameOver = { surv, acc, dodges in
            survived = surv
            accuracy = acc
            cleanDodges = dodges
            progress.recordLevelResult(levelId: levelId, timeSurvived: surv, accuracy: acc, cleanDodges: dodges)
            gameOver = true
        }
        scene = sc
    }
}
