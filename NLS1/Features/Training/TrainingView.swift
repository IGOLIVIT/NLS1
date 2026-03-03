//
//  TrainingView.swift
//  NLS1
//

import SwiftUI

struct TrainingView: View {
    @EnvironmentObject var progress: ProgressStore
    @Binding var path: [Route]

    var body: some View {
        ZStack {
            CosmicGardenBackground(animated: false)
                .ignoresSafeArea(edges: .horizontal)
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.spacingL) {
                    Text("Learn patterns and tactics used in the run.")
                        .font(.subheadline)
                        .foregroundColor(Theme.textSecondary)
                    ForEach(TrainingModule.all, id: \.id) { mod in
                        Button(action: { path.append(.trainingModule(moduleId: mod.id)) }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(mod.title)
                                        .font(.headline)
                                        .foregroundColor(Theme.textPrimary)
                                    Text(mod.subtitle)
                                        .font(.caption)
                                        .foregroundColor(Theme.textSecondary)
                                }
                                Spacer()
                                if progress.isTrainingCompleted(mod.id) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(Theme.electricClover)
                                }
                            }
                            .padding(Theme.spacingM)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Theme.surfaceCard)
                            .cornerRadius(Theme.cornerRadiusM)
                        }
                        .buttonStyle(.plain)
                        .frame(minHeight: Theme.minTapTarget)
                    }
                }
                .padding(Theme.spacingL)
            }
        }
        .navigationTitle("Training")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct TrainingModule: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let lessonBody: String
    static let all: [TrainingModule] = [
        .init(
            id: "lane_reading",
            title: "Lane Reading",
            subtitle: "Anticipate safe lanes",
            lessonBody: "Obstacles move toward you in lanes. Safe gaps appear between them. Look one or two rows ahead and move into a gap before you need it. Shifting at the last moment is risky; early moves give you time to adjust."
        ),
        .init(
            id: "cadence_aim",
            title: "Cadence Aim",
            subtitle: "Rhythm shooting",
            lessonBody: "Pulse shots work best when timed to a rhythm. The reticle shows when you are ready to fire. Wait for the pulse, then tap. Hitting targets in steady cadence builds Charge faster than random firing."
        ),
        .init(
            id: "focus_windows",
            title: "Focus Windows",
            subtitle: "When to hold fire",
            lessonBody: "Sometimes the best shot is no shot. When lanes are crowded or a Shade Drone is about to pass, holding fire avoids wasting your pulse and keeps your rhythm. Shoot when you have a clear window."
        ),
    ]
}
