//
//  HelpModel.swift
//  hackAthon
//
//  Protocolo fijo de emergencia (sin IA):
//  1. Mijo pregunta "¿Está bien?" y cuenta 30 segundos.
//  2. "Sí, estoy bien" (botón o voz) → se cierra, sin molestar a nadie.
//  3. "Necesito ayuda", "no", o no contesta → avisa a la familia por ntfy
//     y le marca al familiar principal.
//  Si la persona ya dijo "me caí" hablando con Mijo, se salta la pregunta.
//

import Foundation
import Observation
import SwiftData
import UIKit

enum FaseDeAyuda: Equatable {
    case preguntando
    case avisando
    /// `enviado`: si ntfy recibió el aviso (puede fallar sin internet).
    case avisado(enviado: Bool)
    /// Dijo que está bien: la pantalla se cierra.
    case bien
}

@Observable
final class HelpModel {
    static let segundosParaContestar = 30

    let voz = VoiceService()
    let nombre: String
    let motivo: Emergencia
    private(set) var fase = FaseDeAyuda.preguntando
    private(set) var segundos = HelpModel.segundosParaContestar
    let familiar: Familiar?
    let ficha: FichaMedica?

    @ObservationIgnored private let acciones: MijoActions
    /// Lo que dijo hablando con Mijo ("me caí"); nil si tocó el botón Ayuda.
    @ObservationIgnored private let frase: String?
    @ObservationIgnored private var cerrada = false

    init(context: ModelContext, nombre: String, motivo: Emergencia, frase: String? = nil) {
        acciones = MijoActions(context: context)
        self.nombre = nombre
        self.motivo = motivo
        self.frase = frase
        familiar = acciones.familiarPrincipal()
        ficha = acciones.fichaMedica()
    }

    /// Texto de la pastilla roja de arriba.
    var etiqueta: String {
        switch motivo {
        case .caida: "Posible caída"
        case .malestar: "Se siente mal"
        case .ayuda: "Pidió ayuda"
        }
    }

    func empezar() async {
        Haptics.warning()
        if frase != nil {
            await pedirAyuda()
            return
        }
        await voz.hablar("\(nombre), ¿está bien? Toque un botón o dígame.")
        guard fase == .preguntando, !cerrada else { return }
        if await voz.pedirPermisos() { try? voz.empezarAEscuchar() }
    }

    /// Cuenta regresiva: si llega a cero sin respuesta, se pide ayuda.
    func contar() async {
        while fase == .preguntando, segundos > 0 {
            try? await Task.sleep(for: .seconds(1))
            guard fase == .preguntando, !cerrada else { return }
            segundos -= 1
        }
        if segundos == 0 { await pedirAyuda() }
    }

    /// Revisa lo que va diciendo mientras escucha.
    func revisar(_ texto: String) {
        guard fase == .preguntando else { return }
        let dicho = EmergencyRouter.normalizar(texto)
        let palabras = dicho.split(separator: " ")
        let estaBien = (dicho.contains("estoy bien") || dicho.contains("todo bien"))
            && !dicho.contains("no estoy bien")
        if estaBien {
            Task { await estoyBien() }
        } else if palabras.contains("no") || dicho.contains("me duele")
                    || dicho.contains("mal") || EmergencyRouter.detectar(dicho) != nil {
            Task { await pedirAyuda() }
        } else if palabras.first == "si" {
            Task { await estoyBien() }
        }
    }

    func estoyBien() async {
        guard fase == .preguntando else { return }
        voz.terminarDeEscuchar()
        fase = .avisando // detiene la cuenta mientras Mijo habla
        await voz.hablar("Qué bueno. Aquí sigo por si me necesita.")
        fase = .bien
    }

    func pedirAyuda() async {
        guard fase == .preguntando else { return }
        voz.terminarDeEscuchar()
        fase = .avisando

        var enviado = false
        if let datos = acciones.datosParaAvisar() {
            let titulo = switch motivo {
            case .caida: "\(datos.nombre) se cayó"
            case .malestar: "\(datos.nombre) se siente mal"
            case .ayuda: "\(datos.nombre) necesita ayuda"
            }
            var mensaje = if let frase { "Le dijo a Mijo: “\(frase)”." }
                else if segundos == 0 { "No contestó en \(Self.segundosParaContestar) segundos." }
                else { "Tocó el botón de ayuda." }
            if let familiar { mensaje += " Mijo le está marcando a \(familiar.nombre)." }
            enviado = await NtfyService.avisar(tema: datos.tema, titulo: titulo, mensaje: mensaje,
                                               prioridad: .urgente, etiquetas: ["rotating_light"])
        }
        guard !cerrada else { return }
        fase = .avisado(enviado: enviado)
        if enviado { Haptics.success() }

        let aviso = enviado ? "Ya le avisé a su familia." : ""
        if let familiar {
            await voz.hablar("Aquí estoy con usted. \(aviso) Ahorita le marco a \(familiar.nombre).")
            if !cerrada { llamar(familiar) }
        } else {
            await voz.hablar("Aquí estoy con usted. \(aviso) Si es urgente, toque Llamar al 911.")
        }
    }

    /// iOS siempre pide un toque en "Llamar": ninguna app puede marcar sola.
    func llamar(_ familiar: Familiar) {
        abrir("tel://\(familiar.telefono.filter(\.isNumber))")
    }

    func llamarAl911() {
        abrir("tel://911")
    }

    func cerrar() {
        cerrada = true
        voz.terminarDeEscuchar()
        voz.callar()
    }

    private func abrir(_ direccion: String) {
        guard let url = URL(string: direccion) else { return }
        UIApplication.shared.open(url)
    }
}
