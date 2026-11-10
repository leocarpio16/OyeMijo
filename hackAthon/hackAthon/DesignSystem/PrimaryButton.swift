//
//  PrimaryButton.swift
//  hackAthon
//
//  Botón grande, de lado a lado: café ("Ya terminé", "Ya me la tomé")
//  o rojo solo para emergencias ("Necesito ayuda").
//

import SwiftUI

struct PrimaryButton: View {
    let title: String
    var systemImage: String?
    var color: Color = Theme.Palette.brandBrown
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Theme.Spacing.s + 2) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 24, weight: .bold))
                }
                Text(title)
                    .font(Theme.Typography.primaryButton)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .foregroundStyle(Theme.Palette.surface)
            .padding(.horizontal, Theme.Spacing.l)
            .frame(maxWidth: .infinity, minHeight: Theme.Size.actionButton)
            .background(color, in: .capsule)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 16) {
        PrimaryButton(title: "Ya terminé") {}
        PrimaryButton(title: "Ya me la tomé", systemImage: "checkmark") {}
        PrimaryButton(title: "Necesito ayuda", systemImage: "exclamationmark.triangle",
                      color: Theme.Palette.help) {}
    }
    .padding(20)
    .background(Theme.Palette.cream)
}
