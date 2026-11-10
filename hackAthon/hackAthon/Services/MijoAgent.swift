//
//  MijoAgent.swift
//  hackAthon
//
//  El "cerebro" de Mijo: una sesión de Foundation Models (la IA que corre
//  dentro del iPhone, sin internet) con instrucciones de nieto y sus
//  herramientas. Recibe lo que dijo la persona y regresa qué contestar.
//  Las emergencias NO pasan por aquí: las ataja antes EmergencyRouter.
//

import Foundation
import FoundationModels

final class MijoAgent {
    private let acciones: MijoActions
    private let nombre: String
    private var sesion: LanguageModelSession?

    /// Frases fijas para cuando la IA no puede contestar.
    static let noDisponible = "Ahorita no puedo pensar bien. Si necesita ayuda, toque el botón rojo de Ayuda."
    static let temaBloqueado = "De eso mejor platíquelo con su familia o su doctor. Si se siente mal, toque el botón rojo de Ayuda."
    static let noEntendi = "Perdón, no le entendí. ¿Me lo repite?"

    /// - Parameter nombre: cómo le habla Mijo a la persona ("Doña Mari").
    init(acciones: MijoActions, nombre: String) {
        self.acciones = acciones
        self.nombre = nombre
    }

    func responder(a frase: String) async -> RespuestaDeMijo {
        acciones.limpiar()
        // "Ok", "sí", "gracias": no son una petición. Si llegan a la IA, a veces
        // inventa que le preguntaron algo (pasó con "Ok" → le dijo la pastilla).
        if let corta = Self.respuestaCorta(a: frase) {
            return RespuestaDeMijo(texto: corta)
        }
        guard case .available = SystemLanguageModel.default.availability else {
            return RespuestaDeMijo(texto: Self.noDisponible)
        }
        do {
            let texto = try await preguntar(frase)
            return RespuestaDeMijo(texto: texto, detalle: acciones.detalle,
                                   etiquetas: acciones.etiquetas, accion: acciones.accion)
        } catch LanguageModelSession.GenerationError.guardrailViolation {
            // El filtro de seguridad de Apple bloqueó el tema (suele pasar con salud).
            sesion = nil
            return RespuestaDeMijo(texto: Self.temaBloqueado)
        } catch LanguageModelSession.GenerationError.exceededContextWindowSize {
            // La plática ya no cabe en la memoria del modelo: se empieza una nueva.
            sesion = nil
            let texto = try? await preguntar(frase)
            return RespuestaDeMijo(texto: texto ?? Self.noEntendi, detalle: acciones.detalle,
                                   etiquetas: acciones.etiquetas, accion: acciones.accion)
        } catch {
            sesion = nil
            return RespuestaDeMijo(texto: Self.noEntendi)
        }
    }

    /// Respuesta fija para frases de una o dos palabras sin petición; nil si hay que pensarla.
    private static func respuestaCorta(a frase: String) -> String? {
        let texto = EmergencyRouter.normalizar(frase)
        let palabras = texto.split(separator: " ")
        guard palabras.count <= 3 else { return nil }
        let agradece = ["gracias", "muchas gracias", "gracias mijo", "muy bien gracias"]
        let saluda = ["hola", "hola mijo", "oye mijo", "mijo", "buenos dias", "buenas tardes", "buenas noches"]
        let asiente = ["ok", "okay", "oki", "sale", "si", "no", "bueno", "ya", "aja", "esta bien",
                       "va", "listo", "orale", "ah", "eh", "este", "mmm", "ajá"]
        if agradece.contains(texto) { return "De nada. Aquí estoy para lo que necesite." }
        if saluda.contains(texto) { return "Aquí estoy. ¿En qué le ayudo?" }
        if asiente.contains(texto) { return "Muy bien. Si necesita algo, nomás dígame." }
        return nil
    }

    private func preguntar(_ frase: String) async throws -> String {
        let sesion = self.sesion ?? nuevaSesion()
        self.sesion = sesion
        let respuesta = try await sesion.respond(to: frase)
        return respuesta.content.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func nuevaSesion() -> LanguageModelSession {
        let ahora = Date.now.formatted(.dateTime.weekday(.wide).hour().minute().locale(Locale(identifier: "es_MX")))
        return LanguageModelSession(
            tools: [
                LlamarFamiliarTool(acciones: acciones),
                MandarWhatsAppTool(acciones: acciones),
                AvisarFamiliaTool(acciones: acciones),
                AbrirAppTool(acciones: acciones),
                BuscarEnYouTubeTool(acciones: acciones),
                CrearRecordatorioMedicinaTool(acciones: acciones),
                ConsultarMedicinaTool(acciones: acciones),
                RegistrarComidaTool(acciones: acciones),
                MarcarTomadaTool(acciones: acciones),
            ],
            instructions: """
            Eres Mijo, el nieto virtual de \(nombre), una persona mayor que vive en México. \
            Siempre le hablas de usted (nunca de tú), con cariño y respeto, en español de México.
            Contesta en una o dos frases cortas y sencillas, sin listas ni símbolos, \
            porque tu respuesta se lee en voz alta.
            Ahora es \(ahora).
            Usa una herramienta solo cuando la persona pida claramente algo que esa herramienta hace: \
            llamar a alguien, mandarle un mensaje por WhatsApp, avisarle a toda su familia, abrir una app, buscar videos en YouTube, guardar un recordatorio de pastilla, saber de sus pastillas, \
            decir que ya se tomó una pastilla o contar si ya comió. \
            Si nombra a una persona ("dile a Leo"), manda WhatsApp; si dice "avisa a mi familia" o "a todos", manda el aviso a la familia.
            Si solo platica o no queda claro qué quiere, contesta amable y pregúntale en qué le ayudas.
            No inventes horarios ni datos: di solo lo que te regresen las herramientas.
            Si dice una hora sin decir si es de la mañana o de la noche, pregúntale.
            No des consejos médicos ni cambies dosis: para eso está su doctor.
            """
        )
    }
}
