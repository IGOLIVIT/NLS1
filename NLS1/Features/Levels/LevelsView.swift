//
//  LevelsView.swift
//  NLS1
//

import SwiftUI

struct LevelsView: View {
    @EnvironmentObject var progress: ProgressStore
    @Binding var path: [Route]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.spacingL) {
                Text("Difficulty")
                    .font(.headline)
                    .foregroundColor(Theme.textPrimary)
                Picker("Difficulty", selection: Binding(
                    get: { progress.selectedDifficulty },
                    set: { progress.selectedDifficulty = $0 }
                )) {
                    ForEach(Difficulty.allCases, id: \.self) { d in
                        Text(d.rawValue.capitalized).tag(d)
                    }
                }
                .pickerStyle(.segmented)

                ForEach(LevelConfig.regions, id: \.name) { region in
                    Text(region.name)
                        .font(.headline)
                        .foregroundColor(Theme.warmGold)
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 140))], spacing: Theme.spacingM) {
                        ForEach(Array(region.levelRange), id: \.self) { levelId in
                            LevelCard(
                                levelId: levelId,
                                difficulty: progress.selectedDifficulty,
                                isUnlocked: progress.isLevelUnlocked(levelId),
                                onTap: { path.append(.run(levelId: levelId)) }
                            )
                        }
                    }
                }
            }
            .padding(Theme.spacingL)
        }
        .background { CosmicGardenBackground(animated: false) }
        .navigationTitle("Levels")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct LevelCard: View {
    let levelId: Int
    let difficulty: Difficulty
    let isUnlocked: Bool
    let onTap: () -> Void

    var body: some View {
        let config = LevelConfig.config(for: levelId, difficulty: difficulty)
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: Theme.spacingS) {
                Text("Level \(levelId)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Theme.textPrimary)
                Text(config.goalDescription)
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
                    .lineLimit(2)
                HStack {
                    if config.glyphPetalsReward > 0 {
                        Label("\(config.glyphPetalsReward)", systemImage: "leaf.fill")
                            .font(.caption2)
                            .foregroundColor(Theme.electricClover)
                    }
                    if config.chargeStampsReward > 0 {
                        Label("\(config.chargeStampsReward)", systemImage: "seal.fill")
                            .font(.caption2)
                            .foregroundColor(Theme.warmGold)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(Theme.spacingM)
            .background(Theme.surfaceCard)
            .cornerRadius(Theme.cornerRadiusM)
            .opacity(isUnlocked ? 1 : 0.6)
        }
        .buttonStyle(.plain)
        .disabled(!isUnlocked)
        .frame(minHeight: Theme.minTapTarget)
    }
}
