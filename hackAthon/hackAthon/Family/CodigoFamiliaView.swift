//
//  CodigoFamiliaView.swift
//  hackAthon
//
//  En el teléfono de la abuela: el código para conectar a un familiar
//  (el modo familia de Mijo o la app ntfy). Se abre manteniendo presionado
//  su nombre en Inicio, para que no lo toque por accidente.
//

import SwiftUI

struct CodigoFamiliaView: View {
    let tema: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xl) {
            RoundIconButton(systemImage: "arrow.left", label: "Regresar") { dismiss() }

            VStack(alignment: .leading, spacing: Theme.Spacing.m) {
                Text("Conectar a la familia")
                    .display(Theme.Typography.titleSize)
                    .foregroundStyle(Theme.Palette.cafe)
                Text("En Mijo de su familiar: «Soy familiar» y este código. También sirve escanearlo con la app ntfy.")
                    .font(Theme.Typography.support)
                    .foregroundStyle(Theme.Palette.cafeSoft)
                    .fixedSize(horizontal: false, vertical: true)
            }

            VStack(spacing: Theme.Spacing.l) {
                QRCode.imagen("https://ntfy.sh/\(tema)")?
                    .resizable()
                    .scaledToFit()
                    .frame(width: Theme.Size.qr, height: Theme.Size.qr)
                    .padding(Theme.Spacing.m + 2)
                    .background(Theme.Palette.surface, in: .rect(cornerRadius: Theme.Radius.input))
                    .accessibilityLabel("Código para conectar a la familia")
                Text(tema)
                    .font(Theme.Typography.contactName)
                    .foregroundStyle(Theme.Palette.cafe)
                    .textSelection(.enabled)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)

            Spacer()

            PrimaryButton(title: "Listo", systemImage: "checkmark") { dismiss() }
        }
        .padding(.horizontal, Theme.Spacing.screen)
        .padding(.vertical, Theme.Spacing.l)
        .background(Theme.Palette.cream.ignoresSafeArea())
    }
}

#Preview {
    CodigoFamiliaView(tema: "mijo-mari-4821")
}
