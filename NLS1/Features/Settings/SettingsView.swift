//
//  SettingsView.swift
//  NLS1
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var progress: ProgressStore
    @Binding var path: [Route]
    @State private var showResetConfirmation = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.spacingL) {
                Text("Stats")
                    .font(.headline)
                    .foregroundColor(Theme.textPrimary)
                VStack(alignment: .leading, spacing: Theme.spacingS) {
                    statRow("Levels completed", "\(progress.levelsCompleted)")
                    statRow("Best accuracy", "\(Int(progress.bestAccuracy))%")
                    statRow("Longest survival", String(format: "%.1fs", progress.longestSurvival))
                    statRow("Trainings completed", "\(progress.trainingsCompleted.count)")
                    statRow("Achievements unlocked", "\(progress.achievementsUnlockedCount())")
                }
                .padding(Theme.spacingM)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Theme.surfaceCard)
                .cornerRadius(Theme.cornerRadiusM)

                PrimaryButton(title: "Reset Progress", action: { showResetConfirmation = true })
                    .padding(.top, Theme.spacingM)
            }
            .padding(Theme.spacingL)
        }
        .background { CosmicGardenBackground(animated: false) }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Reset Progress?", isPresented: $showResetConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                path.removeAll()
                progress.resetProgress()
            }
        } message: {
            Text("All progress, levels, and achievements will be cleared. You will need to complete onboarding again.")
        }
    }

    private func statRow(_ label: String, _ value: String) -> some View {
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
}
