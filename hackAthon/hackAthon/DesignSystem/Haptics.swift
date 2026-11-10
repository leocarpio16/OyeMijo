//
//  Haptics.swift
//  hackAthon
//
//  Vibraciones cortas: confirman con el tacto que el toque sí entró
//  (ayuda a quien no ve bien la pantalla).
//

import UIKit

enum Haptics {
    /// Toque normal de un botón.
    static func tap() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    /// Algo salió bien: "Ya me la tomé", aviso enviado.
    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    /// Alerta: se abre "¿Está bien?".
    static func warning() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
}
