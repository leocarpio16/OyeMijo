//
//  FamilyView.swift
//  hackAthon
//
//  Pantalla del modo familia (el teléfono del nieto o del hijo):
//  - arriba, si está conectado al tema de la abuela,
//  - el aviso más nuevo en grande, con "Ver en el mapa" si trae ubicación,
//  - abajo, los avisos anteriores.
//  Mismos colores que la app de la abuela: rosa y rojo solo para urgencias.
//

import SwiftUI

struct FamilyView: View {
    @State private var modelo: FamilyModel
    /// Flecha de arriba: a la pantalla del código (sin salir del modo familia).
    let onRegresar: () -> Void

    init(tema: String, onRegresar: @escaping () -> Void) {
        _modelo = State(initialValue: FamilyModel(tema: tema))
        self.onRegresar = onRegresar
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.xl) {
                encabezado
                if let ultimo = modelo.avisos.first {
                    AvisoGrande(aviso: ultimo) { modelo.abrirMapa(ultimo) }
                    if modelo.avisos.count > 1 {
                        Text("Antes")
                            .font(Theme.Typography.stepLabel)
                            .foregroundStyle(Theme.Palette.cafeSoft)
                        VStack(spacing: Theme.Spacing.m) {
                            ForEach(modelo.avisos.dropFirst()) { aviso in
                                AvisoRenglon(aviso: aviso) { modelo.abrirMapa(aviso) }
                            }
                        }
                    }
                } else {
                    sinAvisos
                }
            }
            .padding(.horizontal, Theme.Spacing.screen)
            .padding(.vertical, Theme.Spacing.l)
        }
        .scrollIndicators(.hidden)
        .background(Theme.Palette.cream.ignoresSafeArea())
        .animation(.easeInOut(duration: 0.3), value: modelo.avisos)
        .task { await modelo.escuchar() }
    }

    private var encabezado: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.s) {
            HStack {
                RoundIconButton(systemImage: "arrow.left", label: "Regresar al código", action: onRegresar)
                Spacer()
                // El código siempre a la vista, por si otro familiar lo necesita.
                Label(modelo.tema, systemImage: "key")
                    .font(Theme.Typography.cardRow)
                    .foregroundStyle(Theme.Palette.cafeSoft)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .textSelection(.enabled)
            }
            .padding(.bottom, Theme.Spacing.s)
            HStack(spacing: Theme.Spacing.m) {
                MijoAvatar(size: Theme.Size.cardAvatar)
                VStack(alignment: .leading, spacing: 0) {
                    Text("Modo familia")
                        .font(Theme.Typography.cardName)
                        .foregroundStyle(Theme.Palette.cafe)
                    Label(modelo.conectado ? "Escuchando avisos" : "Conectando…",
                          systemImage: modelo.conectado ? "dot.radiowaves.left.and.right" : "wifi.exclamationmark")
                        .font(Theme.Typography.cardRowBold)
                        .foregroundStyle(modelo.conectado ? Theme.Palette.taken : Theme.Palette.cafeSoft)
                }
            }
            Text("Avisos de Mijo")
                .display(Theme.Typography.titleSize)
                .foregroundStyle(Theme.Palette.cafe)
                .padding(.top, Theme.Spacing.m)
        }
    }

    private var sinAvisos: some View {
        VStack(spacing: Theme.Spacing.m) {
            SceneIllustration(symbol: "bell", tint: Theme.Palette.answerGlow)
            Text("Todo tranquilo")
                .display(Theme.Typography.answerSize)
                .foregroundStyle(Theme.Palette.cafe)
            Text("Si Mijo nota algo, el aviso aparece aquí con sonido. Deje la app abierta.")
                .font(Theme.Typography.support)
                .foregroundStyle(Theme.Palette.cafeSoft)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Piezas

/// Ícono y colores según qué tan urgente es.
private extension AvisoFamiliar {
    var icono: String {
        urgente ? "exclamationmark.triangle.fill" : tranquilo ? "checkmark.circle.fill" : "bell.fill"
    }
    var color: Color {
        urgente ? Theme.Palette.help : tranquilo ? Theme.Palette.taken : Theme.Palette.brandBrown
    }
    var fondo: Color {
        urgente ? Theme.Palette.helpGlow : tranquilo ? Theme.Palette.surface : Theme.Palette.answerGlow
    }
    /// "hace 2 minutos"
    var cuando: String {
        fecha.formatted(.relative(presentation: .named).locale(Locale(identifier: "es_MX")))
    }
}

/// El aviso más nuevo, en grande.
private struct AvisoGrande: View {
    let aviso: AvisoFamiliar
    let verMapa: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.l) {
            HStack {
                Label(aviso.urgente ? "Urgente" : "Nuevo", systemImage: aviso.icono)
                    .font(Theme.Typography.alertPill)
                    .foregroundStyle(aviso.color)
                Spacer()
                Text(aviso.cuando)
                    .font(Theme.Typography.cardRow)
                    .foregroundStyle(Theme.Palette.cafeSoft)
            }
            Text(aviso.titulo)
                .display(Theme.Typography.answerSize)
                .foregroundStyle(Theme.Palette.cafe)
                .fixedSize(horizontal: false, vertical: true)
            Text(aviso.mensaje)
                .font(Theme.Typography.support)
                .foregroundStyle(Theme.Palette.cafe)
                .fixedSize(horizontal: false, vertical: true)
            if aviso.mapa != nil {
                PrimaryButton(title: "Ver en el mapa", systemImage: "map",
                              color: aviso.urgente ? Theme.Palette.help : Theme.Palette.brandBrown, action: verMapa)
            }
        }
        .padding(Theme.Spacing.section)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(aviso.fondo, in: .rect(cornerRadius: Theme.Radius.card))
        .shadow(color: Theme.Palette.shadow.opacity(0.08), radius: 16, y: 10)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}

/// Un aviso anterior, en un renglón.
private struct AvisoRenglon: View {
    let aviso: AvisoFamiliar
    let verMapa: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: Theme.Spacing.m) {
            Image(systemName: aviso.icono)
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(aviso.color)
            VStack(alignment: .leading, spacing: 2) {
                Text(aviso.titulo)
                    .font(Theme.Typography.cardRowBold)
                    .foregroundStyle(Theme.Palette.cafe)
                Text(aviso.cuando)
                    .font(Theme.Typography.cardRow)
                    .foregroundStyle(Theme.Palette.cafeSoft)
            }
            Spacer(minLength: 0)
            if aviso.mapa != nil {
                RoundIconButton(systemImage: "map", label: "Ver en el mapa", size: Theme.Size.chip, action: verMapa)
            }
        }
        .padding(Theme.Spacing.l)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.Palette.surface, in: .rect(cornerRadius: Theme.Radius.input))
    }
}

#Preview {
    FamilyView(tema: "mijo-prueba") {}
}
