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
    /// Dijo "me caí", "me siento mal"…: se pasa a la pantalla de ayuda.
    case emergencia(Emergencia)
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
    /// Si no dice nada en este tiempo, se deja de escuchar.
    @ObservationIgnored private var esperaDeSilencio: Task<Void, Never>?
    private static let segundosSinHablar = 8

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
            return
        }
        esperaDeSilencio?.cancel()
        esperaDeSilencio = Task {
            try? await Task.sleep(for: .seconds(Self.segundosSinHablar))
            guard !Task.isCancelled, voz.escuchando, voz.textoEscuchado.isEmpty else { return }
            await terminar()
        }
    }

    /// "Ya terminé" (o se quedó callada): decide qué contestar.
    func terminar() async {
        guard case .escuchando = fase else { return }
        esperaDeSilencio?.cancel()
        frase = voz.terminarDeEscuchar().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !frase.isEmpty else {
            mostrar(RespuestaDeMijo(texto: "No le escuché. Toque el micrófono y dígame otra vez."))
            return
        }
        fase = .pensando
        // Primero el filtro de emergencias, sin IA; lo demás va con el agente.
        if let emergencia = EmergencyRouter.detectar(frase) {
            fase = .emergencia(emergencia)
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
        Haptics.success()
        mostrar(RespuestaDeMijo(texto: "Muy bien, ya lo anoté. Su pastilla de \(medicina.paraQue) está tomada."))
    }

    func cerrar() {
        cerrada = true
        esperaDeSilencio?.cancel()
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

    /// Abre WhatsApp con el mensaje ya escrito (falta 1 toque en Enviar: iOS no deja
    /// que una app mande mensajes sola). Si no tiene WhatsApp, usa Mensajes.
    func mandarMensaje(a familiar: Familiar, texto: String) {
        var digitos = familiar.telefono.filter(\.isNumber)
        // WhatsApp necesita la lada del país: en México, 52 + 10 dígitos.
        if digitos.count == 10 { digitos = "52" + digitos }
        if digitos.count == 13, digitos.hasPrefix("521") { digitos = "52" + digitos.dropFirst(3) }
        var whatsApp = URLComponents(string: "whatsapp://send")!
        whatsApp.queryItems = [.init(name: "phone", value: digitos), .init(name: "text", value: texto)]
        var mensajes = URLComponents()
        mensajes.scheme = "sms"
        mensajes.path = familiar.telefono.filter { $0.isNumber || $0 == "+" }
        mensajes.queryItems = [.init(name: "body", value: texto)]
        guard let urlWhatsApp = whatsApp.url else { return }
        abrir(urlWhatsApp, respaldo: mensajes.url)
    }

    /// Abre otra app; si no está instalada, abre `respaldo` (su página web o Mensajes).
    func abrir(_ url: URL, respaldo: URL?) {
        UIApplication.shared.open(url) { abrio in
            if !abrio, let respaldo {
                UIApplication.shared.open(respaldo)
            }
        }
    }

    private func mostrar(_ respuesta: RespuestaDeMijo) {
        guard !cerrada else { return }
        voz.terminarDeEscuchar()
        fase = .respondiendo(respuesta)
        Task {
            await voz.hablar(respuesta.texto)
            // Mijo abre la llamada o el mensaje él solo en cuanto termina de hablar.
            // El botón café se queda en pantalla por si se cuelga o falla.
            guard !cerrada else { return }
            switch respuesta.accion {
            case .llamar(let familiar): llamar(familiar)
            case .mandarMensaje(let familiar, let texto): mandarMensaje(a: familiar, texto: texto)
            case .abrirApp(_, let url, let web): abrir(url, respaldo: web)
            default: break
            }
        }
    }
}
