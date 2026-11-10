//
//  FamilySetupView.swift
//  hackAthon
//
//  "Soy familiar": el nieto escribe el tema que aparece en el Mijo de la
//  abuela (abajo del código QR) y su teléfono se vuelve el de la familia.
//

import SwiftUI

struct FamilySetupView: View {
    let onConectar: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var texto = ""

    private var tema: String { FamilyModel.limpiar(texto) }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xl) {
            RoundIconButton(systemImage: "arrow.left", label: "Regresar") { dismiss() }

            VStack(alignment: .leading, spacing: Theme.Spacing.m) {
                Text("Soy familiar")
                    .display(Theme.Typography.titleSize)
                    .foregroundStyle(Theme.Palette.cafe)
                Text("Escriba el código que aparece en el Mijo de su familiar, abajo del cuadro QR. Aquí le llegarán sus avisos.")
                    .font(Theme.Typography.support)
                    .foregroundStyle(Theme.Palette.cafeSoft)
                    .fixedSize(horizontal: false, vertical: true)
            }

            VStack(alignment: .leading, spacing: Theme.Spacing.s) {
                Text("Código de Mijo")
                    .font(Theme.Typography.fieldLabel)
                    .foregroundStyle(Theme.Palette.cafeSoft)
                TextField("mijo-mari-4821", text: $texto)
                    .font(Theme.Typography.pill)
                    .foregroundStyle(Theme.Palette.cafe)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding(.horizontal, Theme.Spacing.l)
                    .frame(minHeight: Theme.Size.input)
                    .background(Theme.Palette.surface, in: .rect(cornerRadius: Theme.Radius.input))
                    .overlay {
                        RoundedRectangle(cornerRadius: Theme.Radius.input)
                            .stroke(Theme.Palette.brandAmber, lineWidth: Theme.Size.inputBorder)
                    }
            }

            Spacer()

            PrimaryButton(title: "Conectar", systemImage: "bell") { onConectar(tema) }
                .disabled(tema.isEmpty)
                .opacity(tema.isEmpty ? 0.4 : 1)
        }
        .padding(.horizontal, Theme.Spacing.screen)
        .padding(.vertical, Theme.Spacing.l)
        .background(Theme.Palette.cream.ignoresSafeArea())
    }
}

#Preview {
    FamilySetupView { _ in }
}
