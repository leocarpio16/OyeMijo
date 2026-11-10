//
//  MijoHeader.swift
//  hackAthon
//
//  Panel ámbar con las esquinas de abajo redondeadas y Mijo grande adentro.
//  Va arriba en Inicio, "Mijo escuchando", Bienvenida y ¡Listo!
//

import SwiftUI

struct MijoHeader: View {
    var height: CGFloat = Theme.Size.header
    var mijoSize: CGFloat = Theme.Size.headerMijo

    var body: some View {
        // El panel tiene el color de arriba de la imagen: así no se nota dónde empieza.
        Theme.Palette.brandAmberTop
            .frame(height: height)
            // Mijo va como capa encima: es más ancho que la pantalla y se recorta,
            // pero como capa no empuja ni cambia el ancho de lo demás.
            .overlay(alignment: .top) {
                Image("Mijo")
                    .resizable()
                    .scaledToFill()
                    .frame(width: mijoSize, height: mijoSize)
                    .offset(y: 30) // Mijo un poco abajo, como en el diseño
            }
            .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: Theme.Radius.header,
                                              bottomTrailingRadius: Theme.Radius.header))
            .accessibilityElement()
            .accessibilityLabel("Mijo, su nieto virtual")
    }
}

#Preview {
    MijoHeader().ignoresSafeArea()
}
