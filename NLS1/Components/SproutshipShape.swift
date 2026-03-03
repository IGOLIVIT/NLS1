//
//  SproutshipShape.swift
//  NLS1
//

import SwiftUI

struct SproutshipShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        let cx = rect.midX
        let cy = rect.midY
        var p = Path()
        // Hull: rounded wedge pointing up (canopy front)
        p.move(to: CGPoint(x: cx - w * 0.45, y: cy + h * 0.35))
        p.addQuadCurve(to: CGPoint(x: cx, y: cy - h * 0.45), control: CGPoint(x: cx - w * 0.5, y: cy - h * 0.1))
        p.addQuadCurve(to: CGPoint(x: cx + w * 0.45, y: cy + h * 0.35), control: CGPoint(x: cx + w * 0.5, y: cy - h * 0.1))
        p.addLine(to: CGPoint(x: cx + w * 0.25, y: cy + h * 0.4))
        p.addQuadCurve(to: CGPoint(x: cx - w * 0.25, y: cy + h * 0.4), control: CGPoint(x: cx, y: cy + h * 0.5))
        p.closeSubpath()
        // Fin
        p.move(to: CGPoint(x: cx - w * 0.08, y: cy + h * 0.38))
        p.addLine(to: CGPoint(x: cx, y: cy + h * 0.48))
        p.addLine(to: CGPoint(x: cx + w * 0.08, y: cy + h * 0.38))
        p.closeSubpath()
        return p
    }
}

struct SproutshipView: View {
    var size: CGSize = CGSize(width: 80, height: 60)
    var showGlow: Bool = true
    var overdrive: Bool = false

    var body: some View {
        ZStack {
            if showGlow {
                SproutshipShape()
                    .fill(
                        RadialGradient(
                            colors: [Theme.electricClover.opacity(0.6), Theme.electricClover.opacity(0)],
                            center: .center,
                            startRadius: 0,
                            endRadius: size.width * 0.8
                        )
                    )
                    .frame(width: size.width * 1.4, height: size.height * 1.4)
                    .blur(radius: 8)
            }
            if overdrive {
                SproutshipShape()
                    .stroke(Theme.arcCyan, lineWidth: 2)
                    .frame(width: size.width, height: size.height)
            }
            SproutshipShape()
                .fill(
                    LinearGradient(
                        colors: [Theme.surfaceCard, Theme.electricClover.opacity(0.9)],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .frame(width: size.width, height: size.height)
            SproutshipShape()
                .stroke(Theme.textPrimary.opacity(0.6), lineWidth: 1)
                .frame(width: size.width, height: size.height)
        }
    }
}

#Preview {
    ZStack {
        Color("EmeraldNight").ignoresSafeArea()
        SproutshipView(showGlow: true, overdrive: false)
    }
}
