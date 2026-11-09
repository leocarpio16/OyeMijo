//
//  MijoAvatar.swift
//  hackAthon
//
//  La cara de Mijo en círculo. Reglas de marca: una sola vez por pantalla,
//  nunca por debajo de 29 pt y nunca junto a una alerta de emergencia.
//

import SwiftUI

struct MijoAvatar: View {
    var size: CGFloat = Theme.Size.mijoAvatar

    var body: some View {
        Image("Mijo")
            .resizable()
            .scaledToFill()
            .frame(width: max(size, 29), height: max(size, 29))
            .scaleEffect(1.3) // acerca la cara: el logo trae mucho fondo ámbar alrededor
            .clipShape(.circle)
            .accessibilityLabel("Mijo")
    }
}

#Preview {
    MijoAvatar()
}
