//
//  PrimaryButton.swift
//  hackAthon
//
//  Botón café grande, de lado a lado: "Ya terminé", "Ya me la tomé".
//

import SwiftUI

struct PrimaryButton: View {
    let title: String
    var systemImage: String?
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
            .background(Theme.Palette.brandBrown, in: .capsule)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 16) {
        PrimaryButton(title: "Ya terminé") {}
        PrimaryButton(title: "Ya me la tomé", systemImage: "checkmark") {}
    }
    .padding(20)
    .background(Theme.Palette.cream)
}
