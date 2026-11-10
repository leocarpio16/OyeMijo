//
//  FamilySetupView.swift
//  hackAthon
//
//  "Soy familiar": el nieto escribe el tema que aparece en el Mijo de la
//  abuela (abajo del código QR) y su teléfono se vuelve el de la familia.
//  El código se recuerda: al regresar aquí ya viene escrito.
//  Volver al modo abuela pide confirmación, para no salirse por error.
//

import SwiftUI

struct FamilySetupView: View {
    let onConectar: (String) -> Void
    /// Flecha de arriba: a los avisos (si ya hay código) o a la Bienvenida.
    let onRegresar: () -> Void
    /// "Usar Mijo como abuela"; nil = no se muestra.
    var onSalir: (() -> Void)?
    @State private var texto: String
    @State private var confirmarSalida = false

    init(codigo: String = "", onConectar: @escaping (String) -> Void,
         onRegresar: @escaping () -> Void, onSalir: (() -> Void)? = nil) {
        _texto = State(initialValue: codigo)
        self.onConectar = onConectar
        self.onRegresar = onRegresar
        self.onSalir = onSalir
    }

    private var tema: String { FamilyModel.limpiar(texto) }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xl) {
            RoundIconButton(systemImage: "arrow.left", label: "Regresar", action: onRegresar)

            VStack(alignment: .leading, spacing: Theme.Spacing.m) {
                Text("Soy familiar")
                    .display(Theme.Typography.titleSize)
                    .foregroundStyle(Theme.Palette.cafe)
                Text("Escriba el código de Mijo de su familiar. En su teléfono se ve manteniendo presionado su nombre en Inicio.")
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

            if let onSalir {
                Button("Usar Mijo como abuela") { confirmarSalida = true }
                    .font(Theme.Typography.textButton)
                    .foregroundStyle(Theme.Palette.cafeSoft)
                    .frame(maxWidth: .infinity, minHeight: Theme.Size.textButton)
                    .confirmationDialog("¿Dejar de recibir los avisos en este teléfono?",
                                        isPresented: $confirmarSalida, titleVisibility: .visible) {
                        Button("Sí, usar como abuela", role: .destructive, action: onSalir)
                        Button("Seguir como familiar", role: .cancel) {}
                    } message: {
                        Text("El código se queda guardado por si regresa.")
                    }
            }
        }
        .padding(.horizontal, Theme.Spacing.screen)
        .padding(.vertical, Theme.Spacing.l)
        .background(Theme.Palette.cream.ignoresSafeArea())
    }
}

/// El teléfono en modo familia: la pantalla del código o la de avisos.
struct FamilyRoot: View {
    /// Código de la abuela que escucha este teléfono (se recuerda aunque regrese).
    @AppStorage("temaFamilia") private var tema = ""
    @AppStorage("modoFamilia") private var modoFamilia = false
    /// true = pantalla del código; false = avisos.
    @State private var cambiandoCodigo = false

    var body: some View {
        Group {
            if tema.isEmpty || cambiandoCodigo {
                FamilySetupView(codigo: tema,
                                onConectar: { nuevo in
                                    tema = nuevo
                                    cambiandoCodigo = false
                                },
                                // Sin código todavía, regresar es volver a la Bienvenida: no se pierde nada.
                                onRegresar: {
                                    if tema.isEmpty { modoFamilia = false } else { cambiandoCodigo = false }
                                },
                                onSalir: tema.isEmpty ? nil : { modoFamilia = false })
            } else {
                // .id: si cambia el código, empieza a escuchar el nuevo desde cero.
                FamilyView(tema: tema) { cambiandoCodigo = true }
                    .id(tema)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: cambiandoCodigo)
    }
}

#Preview {
    FamilySetupView(onConectar: { _ in }, onRegresar: {})
}
