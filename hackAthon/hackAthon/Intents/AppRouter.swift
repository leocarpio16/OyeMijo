//
//  AppRouter.swift
//  hackAthon
//
//  Recado entre Siri y la pantalla: cuando Siri abre la app con
//  "Habla con Mijo" o "Mijo, me caí", aquí se anota a dónde ir
//  e Inicio abre esa pantalla.
//

import Observation

@Observable
final class AppRouter {
    static let shared = AppRouter()

    enum Destino {
        case conversacion
        case caida
    }

    /// A dónde ir en cuanto Inicio esté en pantalla; nil si no hay recado.
    var pendiente: Destino?
}
