//
//  CadenceAimDrillView.swift
//  NLS1
//

import SwiftUI

struct CadenceAimDrillView: View {
    var onComplete: (Double) -> Void
    @State private var hits = 0
    @State private var attempts = 0
    @State private var roundEnd = false
    let targetRounds = 8

    var body: some View {
        TimelineView(.animation(minimumInterval: 0.05)) { ctx in
            let phase = (ctx.date.timeIntervalSinceReferenceDate * 0.8).truncatingRemainder(dividingBy: 1)
            let cycle = Int(ctx.date.timeIntervalSinceReferenceDate * 0.8) % 2
            let targetVisible = cycle == 0

            VStack(spacing: Theme.spacingL) {
                Text("Tap when the ring is full")
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
                ZStack {
                    Circle()
                        .stroke(Theme.surfaceCard, lineWidth: 4)
                        .frame(width: 100, height: 100)
                    Circle()
                        .trim(from: 0, to: phase)
                        .stroke(Theme.warmGold, lineWidth: 4)
                        .frame(width: 100, height: 100)
                        .rotationEffect(.degrees(-90))
                    if targetVisible {
                        Circle()
                            .fill(Theme.arcCyan)
                            .frame(width: 24, height: 24)
                    }
                }
                .frame(height: 120)
                .contentShape(Rectangle())
                .onTapGesture {
                    if !roundEnd {
                        attempts += 1
                        if phase > 0.7 && targetVisible {
                            hits += 1
                        }
                        if attempts >= targetRounds {
                            roundEnd = true
                        }
                    }
                }
                Text("Hits: \(hits) / \(attempts)")
                    .font(.caption)
                    .foregroundColor(Theme.textPrimary)
                if roundEnd {
                    PrimaryButton(title: "Finish", action: {
                        onComplete(attempts > 0 ? Double(hits) / Double(attempts) * 100 : 0)
                    })
                }
            }
        }
        .padding(Theme.spacingM)
        .background(Theme.surfaceDark)
        .cornerRadius(Theme.cornerRadiusM)
    }
}
