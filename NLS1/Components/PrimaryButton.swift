//
//  PrimaryButton.swift
//  NLS1
//

import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    var isPrimary: Bool = true
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var style: Style = .primary

    enum Style {
        case primary
        case secondary
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(style == .primary ? Theme.emeraldNight : Theme.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(minHeight: Theme.minTapTarget)
                .padding(.horizontal, Theme.spacingL)
                .background(
                    RoundedRectangle(cornerRadius: Theme.cornerRadiusM)
                        .fill(style == .primary ? Theme.electricClover : Theme.surfaceCard)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.cornerRadiusM)
                        .stroke(style == .secondary ? Theme.electricClover : Color.clear, lineWidth: 1)
                )
        }
        .buttonStyle(PrimaryButtonStyle(isPrimary: style == .primary))
    }
}

struct SecondaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        PrimaryButton(title: title, action: action, style: .secondary)
    }
}
