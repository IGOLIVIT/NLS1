//
//  HomeView.swift
//  NLS1
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var progress: ProgressStore
    @Binding var path: [Route]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.spacingL) {
                Text("Today's Focus")
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
                Text(TodayTip.current)
                    .font(.subheadline)
                    .foregroundColor(Theme.textPrimary)
                    .padding(Theme.spacingM)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Theme.surfaceCard)
                    .cornerRadius(Theme.cornerRadiusM)

                Text("Run")
                    .font(.headline)
                    .foregroundColor(Theme.textPrimary)
                PrimaryButton(title: "Run", action: { path.append(.run(levelId: 1)) })

                Text("Training")
                    .font(.headline)
                    .foregroundColor(Theme.textPrimary)
                PrimaryButton(title: "Training", action: { path.append(.training) })

                Text("Archive")
                    .font(.headline)
                    .foregroundColor(Theme.textPrimary)
                PrimaryButton(title: "Archive", action: { path.append(.archive) })

                HStack(spacing: Theme.spacingM) {
                    SecondaryButton(title: "Levels", action: { path.append(.levels) })
                    SecondaryButton(title: "Settings", action: { path.append(.settings) })
                }
            }
            .padding(Theme.spacingL)
        }
        .background { CosmicGardenBackground(animated: true) }
        .navigationTitle("Hub")
        .navigationBarTitleDisplayMode(.inline)
    }
}
