//
//  LaneReadingDrillView.swift
//  NLS1
//

import SwiftUI

struct LaneReadingDrillView: View {
    var onComplete: (Double) -> Void
    @State private var lanes: [Bool] = (0..<5).map { _ in Bool.random() }
    @State private var selectedLane: Int? = nil
    @State private var round = 0
    @State private var correct = 0
    @State private var showResult = false
    let totalRounds = 5

    var body: some View {
        VStack(spacing: Theme.spacingM) {
            Text("Tap a safe lane (green gap)")
                .font(.caption)
                .foregroundColor(Theme.textSecondary)
            HStack(spacing: Theme.spacingS) {
                ForEach(0..<5, id: \.self) { i in
                    Button(action: { selectLane(i) }) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(laneColor(i))
                            .frame(height: 50)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(Theme.spacingM)
            if showResult {
                Text(selectedLane != nil && lanes[selectedLane!] ? "Correct!" : "Missed")
                    .foregroundColor(selectedLane != nil && lanes[selectedLane!] ? Theme.electricClover : Theme.warmGold)
                if round >= totalRounds {
                    PrimaryButton(title: "Finish", action: {
                        onComplete(Double(correct) / Double(totalRounds) * 100)
                    })
                } else {
                    PrimaryButton(title: "Next", action: nextRound)
                }
            }
        }
        .padding(Theme.spacingM)
        .background(Theme.surfaceDark)
        .cornerRadius(Theme.cornerRadiusM)
    }

    private func laneColor(_ i: Int) -> Color {
        if let s = selectedLane, s == i {
            return lanes[i] ? Theme.electricClover : Theme.surfaceCard
        }
        return lanes[i] ? Theme.electricClover.opacity(0.5) : Theme.surfaceCard
    }

    private func selectLane(_ i: Int) {
        guard selectedLane == nil else { return }
        selectedLane = i
        if lanes[i] { correct += 1 }
        showResult = true
    }

    private func nextRound() {
        round += 1
        selectedLane = nil
        showResult = false
        lanes = (0..<5).map { _ in Bool.random() }
    }
}
