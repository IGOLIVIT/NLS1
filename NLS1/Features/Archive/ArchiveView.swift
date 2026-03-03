//
//  ArchiveView.swift
//  NLS1
//

import SwiftUI

struct ArchiveView: View {
    @EnvironmentObject var progress: ProgressStore
    @Binding var path: [Route]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.spacingL) {
                glossarySection
                backdropsSection
                achievementsSection
            }
            .padding(Theme.spacingL)
        }
        .background { CosmicGardenBackground(animated: false) }
        .navigationTitle("Archive")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var glossarySection: some View {
        VStack(alignment: .leading, spacing: Theme.spacingS) {
            Text("Glossary")
                .font(.headline)
                .foregroundColor(Theme.warmGold)
            ForEach(GlossaryEntry.all, id: \.term) { e in
                VStack(alignment: .leading, spacing: 4) {
                    Text(e.term)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(Theme.textPrimary)
                    Text(e.definition)
                        .font(.caption)
                        .foregroundColor(Theme.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(Theme.spacingM)
                .background(Theme.surfaceCard)
                .cornerRadius(Theme.cornerRadiusS)
            }
        }
    }

    private var backdropsSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacingS) {
            Text("Backdrop Themes")
                .font(.headline)
                .foregroundColor(Theme.warmGold)
            Text("Earn themes by completing achievements.")
                .font(.caption)
                .foregroundColor(Theme.textSecondary)
            HStack(spacing: Theme.spacingM) {
                backdropChip("Default", id: "default")
                backdropChip("Root Nebula", id: "root_nebula")
                backdropChip("Aurora", id: "aurora")
            }
        }
    }

    private func backdropChip(_ name: String, id: String) -> some View {
        let unlocked = id == "default" || progress.achievementsUnlockedCount() > 0
        return Text(name)
            .font(.caption)
            .foregroundColor(unlocked ? Theme.textPrimary : Theme.textSecondary)
            .padding(.horizontal, Theme.spacingM)
            .padding(.vertical, Theme.spacingS)
            .background(unlocked ? Theme.surfaceCard : Theme.surfaceDark)
            .cornerRadius(Theme.cornerRadiusS)
    }

    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacingS) {
            Text("Achievements")
                .font(.headline)
                .foregroundColor(Theme.warmGold)
            ForEach(Achievement.all, id: \.id) { a in
                HStack {
                    Image(systemName: progress.isAchievementUnlocked(a.id) ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(progress.isAchievementUnlocked(a.id) ? Theme.electricClover : Theme.textSecondary)
                    Text(a.name)
                        .foregroundColor(Theme.textPrimary)
                    Spacer()
                }
                .padding(Theme.spacingM)
                .background(Theme.surfaceCard)
                .cornerRadius(Theme.cornerRadiusS)
            }
        }
    }
}

struct GlossaryEntry {
    let term: String
    let definition: String
    static let all: [GlossaryEntry] = [
        .init(term: "Sproutship", definition: "Your hovercraft. Swipe to change lanes, tap to fire pulse shots."),
        .init(term: "Shade Drone", definition: "Moving targets. Hit them in rhythm to build Charge."),
        .init(term: "Bramble Gate", definition: "Stationary lane blocker. Dodge by changing lanes."),
        .init(term: "Flux Orb", definition: "Slow-moving hazard. Plan your path around them."),
        .init(term: "Overdrive", definition: "Activate when Charge is full for slow-motion and wider shots."),
        .init(term: "Charge", definition: "Builds when you hit targets in cadence. Full Charge enables Overdrive."),
    ]
}

struct Achievement {
    let id: String
    let name: String
    static let all: [Achievement] = [
        .init(id: "first_run", name: "First Run"),
        .init(id: "clean_run_1", name: "Clean Run I"),
        .init(id: "clean_run_2", name: "Clean Run II"),
        .init(id: "clean_run_3", name: "Clean Run III"),
        .init(id: "cadence_keeper", name: "Cadence Keeper"),
        .init(id: "no_hit_streak", name: "No-Hit Streak"),
        .init(id: "training_graduate", name: "Training Graduate"),
    ]
}
