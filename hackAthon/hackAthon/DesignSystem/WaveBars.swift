//
//  WaveBars.swift
//  hackAthon
//
//  Barritas que suben y bajan con la voz mientras Mijo escucha:
//  así la persona ve que sí la está oyendo.
//

import SwiftUI

struct WaveBars: View {
    /// Qué tan fuerte se oye, de 0 (silencio) a 1.
    var level: Double
    /// true mientras Mijo piensa: las barras ondulan solas, despacio.
    var thinking = false

    // Altos del diseño: del borde al centro. Se repiten en espejo.
    private static let half: [CGFloat] = [10, 14, 18, 24, 32, 42, 54, 66]
    private static let heights = half + [78] + half.reversed()

    var body: some View {
        TimelineView(.animation(paused: !thinking)) { contexto in
            let t = contexto.date.timeIntervalSinceReferenceDate
            HStack(spacing: Theme.Size.waveBar) {
                ForEach(Self.heights.indices, id: \.self) { i in
                    let full = Self.heights[i]
                    // Pensando: una ola que recorre las barras de izquierda a derecha.
                    let altura = thinking ? 0.3 + 0.25 * sin(t * 4 - Double(i) * 0.6) : level
                    Capsule()
                        .fill(Theme.Palette.brandBrown)
                        .opacity(0.35 + 0.65 * (full - 10) / 68)
                        .frame(width: Theme.Size.waveBar, height: 10 + (full - 10) * altura)
                }
            }
        }
        .frame(height: 80)
        .animation(.easeOut(duration: 0.12), value: level)
        .accessibilityHidden(true)
    }
}

#Preview {
    VStack(spacing: 24) {
        WaveBars(level: 1)
        WaveBars(level: 0.4)
        WaveBars(level: 0, thinking: true)
    }
    .padding(24)
    .background(Theme.Palette.cream)
}
