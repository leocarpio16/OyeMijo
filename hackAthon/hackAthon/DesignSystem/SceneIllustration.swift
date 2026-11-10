//
//  SceneIllustration.swift
//  hackAthon
//
//  Ilustración grande de la pantalla de caída, armada con piezas simples
//  (inspirada en el diseño que eligió Leo): un sol tenue, una mancha suave,
//  dos hojas a los lados y, al centro, un dibujo de línea (SF Symbol).
//  Los colores los pone quien la usa; las hojas siempre van en café y ámbar.
//

import SwiftUI

struct SceneIllustration: View {
    /// Nombre del SF Symbol del centro.
    let symbol: String
    /// Color de la mancha de fondo.
    var tint: Color = Theme.Palette.answerGlow
    var symbolColor: Color = Theme.Palette.cafe

    var body: some View {
        ZStack {
            Circle()
                .fill(tint.opacity(0.6))
                .frame(width: Theme.Size.sun, height: Theme.Size.sun)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(.leading, Theme.Spacing.xl)

            BlobShape()
                .fill(tint)
                .padding(.horizontal, Theme.Spacing.l)
                .padding(.top, Theme.Spacing.xl)

            // Hojas: la oscura a la izquierda, la clara y una chica a la derecha.
            HStack(alignment: .bottom) {
                LeafShape()
                    .fill(Theme.Palette.brandBrown)
                    .frame(width: Theme.Size.leaf * 0.55, height: Theme.Size.leaf)
                    .rotationEffect(.degrees(-28), anchor: .bottom)
                Spacer()
                LeafShape()
                    .fill(Theme.Palette.brandBrown)
                    .frame(width: Theme.Size.leaf * 0.32, height: Theme.Size.leaf * 0.6)
                    .rotationEffect(.degrees(8), anchor: .bottom)
                LeafShape()
                    .fill(Theme.Palette.leafLight)
                    .frame(width: Theme.Size.leaf * 0.6, height: Theme.Size.leaf * 1.15)
                    .rotationEffect(.degrees(24), anchor: .bottom)
            }
            .padding(.horizontal, Theme.Spacing.xl)
            .frame(maxHeight: .infinity, alignment: .bottom)

            Image(systemName: symbol)
                .font(.system(size: Theme.Size.illustration, weight: .light))
                .foregroundStyle(symbolColor)
                .contentTransition(.symbolEffect(.replace))
                .padding(.top, Theme.Spacing.xl)
        }
        .frame(height: Theme.Size.scene)
        .accessibilityHidden(true)
    }
}

/// Hoja puntiaguda con su nervadura al centro (un hueco del color del fondo).
struct LeafShape: Shape {
    func path(in rect: CGRect) -> Path {
        func punto(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + x * rect.width, y: rect.minY + y * rect.height)
        }
        var hoja = Path()
        hoja.move(to: punto(0.5, 1))
        hoja.addCurve(to: punto(0.5, 0), control1: punto(-0.25, 0.75), control2: punto(0.05, 0.2))
        hoja.addCurve(to: punto(0.5, 1), control1: punto(0.95, 0.2), control2: punto(1.25, 0.75))
        hoja.closeSubpath()
        // La nervadura se resta de la hoja para que se vea el fondo.
        var nervio = Path()
        nervio.move(to: punto(0.5, 0.95))
        nervio.addLine(to: punto(0.5, 0.22))
        let linea = nervio.strokedPath(StrokeStyle(lineWidth: max(rect.width * 0.04, 1.5), lineCap: .round))
        return hoja.subtracting(linea)
    }
}

#Preview {
    VStack(spacing: 32) {
        SceneIllustration(symbol: "figure.fall", tint: Theme.Palette.helpGlow)
        SceneIllustration(symbol: "figure.flexibility")
    }
    .padding(24)
    .background(Theme.Palette.cream)
}
