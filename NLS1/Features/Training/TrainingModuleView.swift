//
//  TrainingModuleView.swift
//  NLS1
//

import SwiftUI

struct TrainingModuleView: View {
    @EnvironmentObject var progress: ProgressStore
    @Binding var path: [Route]
    let moduleId: String
    @State private var drillComplete = false
    @State private var drillScore: Double = 0
    @State private var drillKey = 0

    private var module: TrainingModule? {
        TrainingModule.all.first { $0.id == moduleId }
    }

    var body: some View {
        ZStack {
            CosmicGardenBackground(animated: false)
                .ignoresSafeArea(edges: .horizontal)
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.spacingL) {
                    if let mod = module {
                        Text(mod.title)
                            .font(.title2)
                            .foregroundColor(Theme.textPrimary)
                        Text(mod.lessonBody)
                            .font(.body)
                            .foregroundColor(Theme.textSecondary)

                        Text("Drill")
                            .font(.headline)
                            .foregroundColor(Theme.warmGold)
                        drillView(for: mod)
                            .id(drillKey)

                        if drillComplete {
                            Text("Score: \(Int(drillScore))")
                                .font(.headline)
                                .foregroundColor(Theme.electricClover)
                            PrimaryButton(title: "Mark Complete", action: {
                                progress.completeTraining(mod.id)
                                path.removeLast()
                            })
                            SecondaryButton(title: "Try Again", action: {
                                drillComplete = false
                                drillScore = 0
                                drillKey += 1
                            })
                        }
                    } else {
                        Text("Module not found.")
                            .foregroundColor(Theme.textSecondary)
                        PrimaryButton(title: "Back to Training", action: { path.removeLast() })
                    }
                }
                .padding(Theme.spacingL)
            }
        }
        .navigationTitle(module?.title ?? "Training")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func drillView(for mod: TrainingModule) -> some View {
        switch mod.id {
        case "lane_reading":
            LaneReadingDrillView(onComplete: { score in
                drillScore = score
                drillComplete = true
            })
        case "cadence_aim":
            CadenceAimDrillView(onComplete: { score in
                drillScore = score
                drillComplete = true
            })
        case "focus_windows":
            FocusWindowsDrillView(onComplete: { score in
                drillScore = score
                drillComplete = true
            })
        default:
            Text("Drill not available.")
                .foregroundColor(Theme.textSecondary)
        }
    }
}
