//
//  ConversationModel.swift
//  hackAthon
//
//  Lleva el hilo de una plática con Mijo:
//  escuchar → (¿emergencia?) → pensar con la IA → contestar en voz.
//  Las pantallas solo leen `fase` y llaman a estas funciones.
//

import Foundation
import Observation
import SwiftData
import UIKit

enum FaseDeConversacion {
    case escuchando
    case pensando
    case respondiendo(RespuestaDeMijo)
}

@Observable
final class ConversationModel {
    let voz = VoiceService()
    let nombre: String
    private(set) var fase = FaseDeConversacion.escuchando
    /// Lo último que dijo la persona.
    private(set) var frase = ""

    @ObservationIgnored private let acciones: MijoActions
    @ObservationIgnored private let agente: MijoAgent
    /// true cuando ya se cerró la pantalla: Mijo no debe seguir hablando.
    @ObservationIgnored private var cerrada = false

    init(context: ModelContext, nombre: String) {
        self.nombre = nombre
        acciones = MijoActions(context: context)
        agente = MijoAgent(acciones: acciones, nombre: nombre)
    }

    /// Pide permisos (solo la primera vez) y empieza a escuchar.
    func escuchar() async {
        frase = ""
        fase = .escuchando
        guard await voz.pedirPermisos() else {
            mostrar(RespuestaDeMijo(texto: "Necesito permiso para usar el micrófono. Pídale a su familia que lo active en Ajustes."))
            return
        }
        do {
            try voz.empezarAEscuchar()
        } catch {
            mostrar(RespuestaDeMijo(texto: "Ahorita no puedo escucharle. Inténtelo otra vez en un momento."))
        }
    }

    /// "Ya terminé" (o se quedó callada): decide qué contestar.
    func terminar() async {
        guard case .escuchando = fase else { return }
        frase = voz.terminarDeEscuchar().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !frase.isEmpty else {
            mostrar(RespuestaDeMijo(texto: MijoAgent.noEntendi))
            return
        }
        fase = .pensando
        // Primero el filtro de emergencias, sin IA; lo demás va con el agente.
        if let emergencia = EmergencyRouter.detectar(frase) {
            mostrar(await atenderEmergencia(emergencia))
        } else {
            mostrar(await agente.responder(a: frase))
        }
    }

    /// Botón "Escuchar": Mijo repite su respuesta.
    func repetir() {
        guard case .respondiendo(let respuesta) = fase else { return }
        Task { await voz.hablar(respuesta.texto) }
    }

    /// "Ya me la tomé".
    func marcarTomada(_ medicina: Medicina) {
        acciones.marcarTomada(medicina)
        mostrar(RespuestaDeMijo(texto: "Muy bien, ya lo anoté. Su pastilla de \(medicina.paraQue) está tomada."))
    }

    func cerrar() {
        cerrada = true
        voz.terminarDeEscuchar()
        voz.callar()
    }

    /// Llama a un familiar. iOS siempre pide un toque en "Llamar" antes de marcar:
    /// ninguna app puede hacer una llamada sin que la persona lo confirme.
    func llamar(_ familiar: Familiar) {
        let numero = familiar.telefono.filter(\.isNumber)
        guard let url = URL(string: "tel://\(numero)") else { return }
        UIApplication.shared.open(url)
    }

    private func mostrar(_ respuesta: RespuestaDeMijo) {
        guard !cerrada else { return }
        voz.terminarDeEscuchar()
        fase = .respondiendo(respuesta)
        Task {
            await voz.hablar(respuesta.texto)
            // Mijo hace la llamada él solo en cuanto termina de hablar.
            // El botón café se queda en pantalla por si se cuelga o falla.
            if !cerrada, case .llamar(let familiar) = respuesta.accion {
                llamar(familiar)
            }
        }
    }

    /// Emergencia (sin IA): avisa a la familia por ntfy y le marca al familiar principal.
    /// El protocolo completo (¿le duele?, dirección, ficha médica) es el Bloque 4.
    private func atenderEmergencia(_ emergencia: Emergencia) async -> RespuestaDeMijo {
        let familiar = acciones.familiarPrincipal()
        var avisado = false
        if let datos = acciones.datosParaAvisar() {
            let titulo = switch emergencia {
            case .caida: "\(datos.nombre) se cayó"
            case .malestar: "\(datos.nombre) se siente mal"
            case .ayuda: "\(datos.nombre) pidió ayuda"
            }
            var mensaje = "Le dijo a Mijo: “\(frase)”."
            if let familiar { mensaje += " Mijo le está marcando a \(familiar.nombre)." }
            avisado = await NtfyService.avisar(tema: datos.tema, titulo: titulo, mensaje: mensaje,
                                               prioridad: .urgente, etiquetas: ["rotating_light"])
        }

        guard let familiar else {
            return RespuestaDeMijo(texto: "Aquí estoy con usted. Si es urgente, llame al 911.")
        }
        let texto = avisado
            ? "Aquí estoy con usted. Ya le avisé a su familia y ahorita le marco a \(familiar.nombre)."
            : "Aquí estoy con usted. Ahorita le marco a \(familiar.nombre)."
        return RespuestaDeMijo(texto: texto,
                               detalle: avisado ? "Su familia ya recibió el aviso" : nil,
                               etiquetas: [familiar.nombre, "Su \(familiar.parentesco)"],
                               accion: .llamar(familiar))
    }
}
