//
//  CosmicGardenBackground.swift
//  NLS1
//
//  Layered cosmic-garden style background: gradients, starfield, botanical curves.
//

import SwiftUI

struct CosmicGardenBackground: View {
    /// Optional: subtle slow animation (e.g. for onboarding/home). Set false for lists to avoid distraction.
    var animated: Bool = true

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            ZStack {
                // 1) Base gradient — deep emerald to darker bottom
                LinearGradient(
                    colors: [
                        Theme.emeraldNight,
                        Theme.surfaceDark,
                        Theme.emeraldNight
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                // 2) Radial accent glows (nebula-like)
                if animated {
                    TimelineView(.animation(minimumInterval: 0.03)) { ctx in
                        let t = ctx.date.timeIntervalSinceReferenceDate
                        ZStack {
                            radialGlow(
                                color: Theme.electricClover,
                                center: CGPoint(x: w * 0.2, y: h * 0.75),
                                radius: w * 0.9,
                                opacity: 0.12 + 0.03 * sin(t * 0.5)
                            )
                            radialGlow(
                                color: Theme.arcCyan,
                                center: CGPoint(x: w * 0.85, y: h * 0.2),
                                radius: w * 0.7,
                                opacity: 0.08 + 0.02 * sin(t * 0.4 + 1)
                            )
                            radialGlow(
                                color: Theme.warmGold,
                                center: CGPoint(x: w * 0.5, y: h * 0.5),
                                radius: w * 0.9,
                                opacity: 0.05 + 0.02 * sin(t * 0.3 + 2)
                            )
                        }
                    }
                } else {
                    ZStack {
                        radialGlow(color: Theme.electricClover, center: CGPoint(x: w * 0.2, y: h * 0.75), radius: w * 0.9, opacity: 0.12)
                        radialGlow(color: Theme.arcCyan, center: CGPoint(x: w * 0.85, y: h * 0.2), radius: w * 0.7, opacity: 0.08)
                        radialGlow(color: Theme.warmGold, center: CGPoint(x: w * 0.5, y: h * 0.5), radius: w * 0.9, opacity: 0.06)
                    }
                }

                // 3) Starfield (deterministic positions for performance)
                StarfieldView(size: CGSize(width: w, height: h))

                // 4) Botanical / geometric curves (tendrils)
                BotanicalCurvesView(size: CGSize(width: w, height: h))
            }
        }
        .ignoresSafeArea()
    }

    private func radialGlow(color: Color, center: CGPoint, radius: CGFloat, opacity: Double) -> some View {
        RadialGradient(
            colors: [color.opacity(opacity), color.opacity(0.02), Color.clear],
            center: .center,
            startRadius: 0,
            endRadius: radius
        )
        .frame(width: radius * 2, height: radius * 2)
        .position(center)
    }
}

// MARK: - Starfield (Canvas for performance)
private struct StarfieldView: View {
    let size: CGSize
    private static let starCount = 72
    private static let positions: [(CGFloat, CGFloat)] = {
        var rng = SeededRNG(seed: 39987)
        return (0..<starCount).map { _ in
            (CGFloat(rng.next()) / CGFloat(UInt64.max), CGFloat(rng.next()) / CGFloat(UInt64.max))
        }
    }()
    private static let scales: [CGFloat] = {
        var rng = SeededRNG(seed: 77771)
        return (0..<starCount).map { _ in 0.4 + CGFloat(rng.next() % 100) / 250 }
    }()
    private static let alphas: [Double] = {
        var rng = SeededRNG(seed: 12345)
        return (0..<starCount).map { _ in 0.25 + Double(rng.next() % 80) / 200 }
    }()

    var body: some View {
        Canvas { ctx, canvasSize in
            let w = canvasSize.width
            let h = canvasSize.height
            for i in 0..<Self.starCount {
                let (nx, ny) = Self.positions[i]
                let x = nx * w
                let y = ny * h
                let r = Self.scales[i] * 1.8
                let alpha = Self.alphas[i]
                let rect = CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)
                ctx.fill(
                    Path(ellipseIn: rect),
                    with: .color(Theme.textPrimary.opacity(alpha))
                )
            }
        }
        .frame(width: size.width, height: size.height)
    }
}

private struct SeededRNG {
    private var state: UInt64
    init(seed: UInt64) { state = seed }
    mutating func next() -> UInt64 {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return state
    }
}

// MARK: - Botanical curves (soft tendrils / arcs)
private struct BotanicalCurvesView: View {
    let size: CGSize
    var body: some View {
        Canvas { ctx, canvasSize in
            let w = canvasSize.width
            let h = canvasSize.height
            // Tendril 1: left side, gentle S
            var p1 = Path()
            p1.move(to: CGPoint(x: 0, y: h * 0.3))
            p1.addCurve(
                to: CGPoint(x: w * 0.35, y: h * 0.7),
                control1: CGPoint(x: w * 0.1, y: h * 0.5),
                control2: CGPoint(x: w * 0.25, y: h * 0.6)
            )
            ctx.stroke(p1, with: .color(Theme.electricClover.opacity(0.08)), lineWidth: 1.5)

            // Tendril 2: right side
            var p2 = Path()
            p2.move(to: CGPoint(x: w, y: h * 0.5))
            p2.addCurve(
                to: CGPoint(x: w * 0.6, y: h * 0.15),
                control1: CGPoint(x: w * 0.85, y: h * 0.3),
                control2: CGPoint(x: w * 0.7, y: h * 0.2)
            )
            ctx.stroke(p2, with: .color(Theme.arcCyan.opacity(0.07)), lineWidth: 1.2)

            // Arc 3: top horizontal sweep
            var p3 = Path()
            p3.move(to: CGPoint(x: w * 0.1, y: h * 0.12))
            p3.addQuadCurve(to: CGPoint(x: w * 0.9, y: h * 0.08), control: CGPoint(x: w * 0.5, y: 0))
            ctx.stroke(p3, with: .color(Theme.warmGold.opacity(0.06)), lineWidth: 1)
        }
        .frame(width: size.width, height: size.height)
    }
}

#Preview("Cosmic Garden Background") {
    ZStack {
        CosmicGardenBackground(animated: true)
        Text("Preview")
            .foregroundColor(Theme.textPrimary)
    }
    .frame(height: 400)
}
