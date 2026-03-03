//
//  OnboardingView.swift
//  NLS1
//

import SwiftUI

struct OnboardingView: View {
    @Binding var completed: Bool
    @State private var page: Int = 0

    var body: some View {
        ZStack {
            CosmicGardenBackground(animated: true)
            VStack(spacing: 0) {
                TabView(selection: $page) {
                    page1.tag(0)
                    page2.tag(1)
                    page3.tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))

                PrimaryButton(title: "Continue", action: {
                    completed = true
                })
                .padding(Theme.spacingL)
            }
        }
        .foregroundColor(Theme.textPrimary)
    }

    private var page1: some View {
        VStack(spacing: Theme.spacingXL) {
            Spacer()
            Text("Pilot the Sproutship")
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            SproutshipView(size: CGSize(width: 120, height: 90), showGlow: true)
                .modifier(BobbingModifier())
            Text("Your craft responds to every shift. Steer with swipes, stay in the lane.")
                .font(.body)
                .foregroundColor(Theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Theme.spacingL)
            Spacer()
        }
    }

    private var page2: some View {
        VStack(spacing: Theme.spacingXL) {
            Spacer()
            Text("Dodge the Shifts")
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            ZStack {
                LaneLinesPreview()
                SproutshipView(size: CGSize(width: 80, height: 60), showGlow: false)
            }
            .frame(height: 160)
            Text("Lanes move and shift. Read the gaps and move before obstacles reach you.")
                .font(.body)
                .foregroundColor(Theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Theme.spacingL)
            Spacer()
        }
    }

    private var page3: some View {
        VStack(spacing: Theme.spacingXL) {
            Spacer()
            Text("Aim with Rhythm")
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            ReticlePreview()
                .frame(width: 100, height: 100)
            Text("Time your shots with the pulse. Hit targets in rhythm to build Charge.")
                .font(.body)
                .foregroundColor(Theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Theme.spacingL)
            Spacer()
        }
    }
}

private struct BobbingModifier: ViewModifier {
    func body(content: Content) -> some View {
        TimelineView(.animation(minimumInterval: 0.05)) { ctx in
            content
                .offset(y: 4 * sin(ctx.date.timeIntervalSinceReferenceDate * 2))
        }
    }
}

private struct LaneLinesPreview: View {
    @State private var offset: CGFloat = 0
    var body: some View {
        GeometryReader { g in
            let w = g.size.width
            HStack(spacing: 0) {
                ForEach(0..<5, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Theme.electricClover.opacity(0.4))
                        .frame(width: max(4, w / 5 - 8))
                        .offset(x: offset + CGFloat(i) * 20)
                }
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) { offset = -40 }
        }
    }
}

private struct ReticlePreview: View {
    @State private var scale: CGFloat = 1
    var body: some View {
        ZStack {
            Circle()
                .stroke(Theme.warmGold, lineWidth: 2)
                .scaleEffect(scale)
            Circle()
                .stroke(Theme.arcCyan.opacity(0.8), lineWidth: 1)
                .scaleEffect(scale * 0.6)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) { scale = 1.2 }
        }
    }
}
