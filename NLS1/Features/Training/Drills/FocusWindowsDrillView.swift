//
//  FocusWindowsDrillView.swift
//  NLS1
//

import SwiftUI

struct FocusWindowsDrillView: View {
    var onComplete: (Double) -> Void
    @State private var windowOpen = false
    @State private var targetPresent = false
    @State private var hits = 0
    @State private var wrongTaps = 0
    @State private var round = 0
    @State private var showState = false
    let totalRounds = 6

    var body: some View {
        VStack(spacing: Theme.spacingL) {
            Text("Tap only when the window is green and the target is visible")
                .font(.caption)
                .foregroundColor(Theme.textSecondary)
                .multilineTextAlignment(.center)
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(windowOpen ? Theme.electricClover.opacity(0.3) : Theme.surfaceCard)
                    .frame(width: 120, height: 80)
                if windowOpen && targetPresent {
                    Circle()
                        .fill(Theme.arcCyan)
                        .frame(width: 30, height: 30)
                }
            }
            .frame(height: 100)
            .onTapGesture {
                if windowOpen && targetPresent {
                    hits += 1
                } else if windowOpen || targetPresent {
                    wrongTaps += 1
                }
                nextRound()
            }
            if round > 0 {
                Text("Correct: \(hits) — Avoid wrong taps: \(wrongTaps)")
                    .font(.caption)
                    .foregroundColor(Theme.textPrimary)
            }
            if round > totalRounds {
                PrimaryButton(title: "Finish", action: {
                    let score = max(0, 100 - Double(wrongTaps) * 15 + Double(hits) * 10)
                    onComplete(min(100, score))
                })
            }
        }
        .padding(Theme.spacingM)
        .background(Theme.surfaceDark)
        .cornerRadius(Theme.cornerRadiusM)
        .onAppear {
            if round == 0 {
                round = 1
                windowOpen = Bool.random()
                targetPresent = windowOpen && Bool.random()
            }
        }
    }

    private func nextRound() {
        round += 1
        if round > totalRounds { return }
        windowOpen = Bool.random()
        targetPresent = windowOpen && Bool.random()
    }
}
