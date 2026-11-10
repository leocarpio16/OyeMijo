//
//  StepDots.swift
//  hackAthon
//
//  Puntitos de avance del registro y "Paso 2 de 4" debajo.
//  Hechos: café · actual: ámbar y largo · pendientes: café clarito.
//

import SwiftUI

struct StepDots: View {
    /// Paso actual, empezando en 1.
    let current: Int
    let total: Int

    var body: some View {
        VStack(spacing: Theme.Spacing.s) {
            HStack(spacing: 5) {
                ForEach(1...total, id: \.self) { paso in
                    Capsule()
                        .fill(paso == current ? Theme.Palette.brandAmber
                              : paso < current ? Theme.Palette.brandBrown : Theme.Palette.stepPending)
                        .frame(width: paso == current ? Theme.Size.stepDotActive : Theme.Size.stepDot,
                               height: Theme.Size.stepDot)
                }
            }
            Text("Paso \(current) de \(total)")
                .font(Theme.Typography.stepLabel)
                .foregroundStyle(Theme.Palette.cafeSoft)
        }
        .padding(.top, Theme.Spacing.s)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Paso \(current) de \(total)")
    }
}

#Preview {
    StepDots(current: 2, total: 4).padding().background(Theme.Palette.cream)
}
