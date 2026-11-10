//
//  BlobShape.swift
//  hackAthon
//
//  Mancha suave de forma irregular que va detrás de una ilustración grande
//  (pantalla de caída). Se dibuja con 4 curvas dentro del rectángulo que
//  le toque; el color lo pone quien la usa con `.fill(...)`.
//

import SwiftUI

struct BlobShape: Shape {
    func path(in rect: CGRect) -> Path {
        // Puntos en proporción (0 a 1) del rectángulo, para que la forma escale.
        func punto(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + x * rect.width, y: rect.minY + y * rect.height)
        }
        var path = Path()
        path.move(to: punto(0.50, 0.02))
        path.addCurve(to: punto(0.98, 0.44), control1: punto(0.80, 0.00), control2: punto(1.00, 0.20))
        path.addCurve(to: punto(0.58, 0.98), control1: punto(0.96, 0.72), control2: punto(0.80, 0.96))
        path.addCurve(to: punto(0.04, 0.70), control1: punto(0.34, 1.00), control2: punto(0.10, 0.92))
        path.addCurve(to: punto(0.50, 0.02), control1: punto(-0.02, 0.44), control2: punto(0.18, 0.04))
        path.closeSubpath()
        return path
    }
}

#Preview {
    BlobShape()
        .fill(Theme.Palette.helpGlow)
        .frame(width: 320, height: 260)
        .padding(40)
        .background(Theme.Palette.cream)
}
