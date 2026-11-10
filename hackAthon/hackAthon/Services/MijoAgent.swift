//
//  MijoAgent.swift
//  hackAthon
//
//  El "cerebro" de Mijo. Recibe lo que dijo la persona y regresa qué contestar:
//    1. Peticiones conocidas ("ábreme Netflix", "dile a Leo que…"): se entienden
//       por palabras clave (ComandosDeVoz) y se hacen al momento, sin IA.
//    2. Todo lo demás (plática): una sesión de Foundation Models, la IA que corre
//       dentro del iPhone sin internet, con instrucciones de nieto y 3 herramientas.
//  Las emergencias NO pasan por aquí: las ataja antes EmergencyRouter.
//

import Foundation
import FoundationModels

final class MijoAgent {
    private let acciones: MijoActions
    private let nombre: String
    private var sesion: LanguageModelSession?
    /// Pregunta que Mijo dejó en el aire y espera respuesta en la siguiente frase.
    private var pendiente: Pendiente?

    private enum Pendiente {
        /// "¿De la mañana o de la noche?"
        case periodo(paraQue: String, hora: Int, minuto: Int)
        /// "¿Ya se la tomó?"
        case toma(Medicina)
    }

    private struct TardoDemasiado: Error {}
    /// Si la IA no contesta en este tiempo, Mijo lo dice en vez de quedarse pensando.
    private static let segundosParaPensar = 12

    /// Frases fijas para cuando la IA no puede contestar.
    static let noDisponible = "Ahorita no puedo pensar bien. Si necesita ayuda, toque el botón rojo de Ayuda."
    static let temaBloqueado = "De eso mejor platíquelo con su familia o su doctor. Si se siente mal, toque el botón rojo de Ayuda."
    static let noEntendi = "Perdón, no le entendí. ¿Me lo repite?"
    static let tardeMucho = "Perdón, me tardé mucho pensando. ¿Me lo dice otra vez?"

    /// - Parameter nombre: cómo le habla Mijo a la persona ("Doña Mari").
    init(acciones: MijoActions, nombre: String) {
        self.acciones = acciones
        self.nombre = nombre
    }

    func responder(a frase: String) async -> RespuestaDeMijo {
        acciones.limpiar()
        // Primero lo que se entiende sin IA: respuesta a una pregunta de Mijo o una petición conocida.
        if let pendiente, let respuesta = contestar(pendiente, con: frase) {
            self.pendiente = nil
            return respuesta
        }
        pendiente = nil
        if let orden = ComandosDeVoz.entender(frase) {
            return await cumplir(orden)
        }
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
            // Si usó una herramienta, se dice la frase ya redactada (la IA a veces la cambiaba por otra cosa).
            return hecho(o: texto)
        } catch is TardoDemasiado {
            sesion = nil
            return hecho(o: Self.tardeMucho)
        } catch LanguageModelSession.GenerationError.guardrailViolation {
            // El filtro de seguridad de Apple bloqueó el tema (suele pasar con salud).
            sesion = nil
            return RespuestaDeMijo(texto: Self.temaBloqueado)
        } catch LanguageModelSession.GenerationError.exceededContextWindowSize {
            // La plática ya no cabe en la memoria del modelo: se empieza una nueva.
            sesion = nil
            let texto = try? await preguntar(frase)
            return hecho(o: texto ?? Self.noEntendi)
        } catch {
            sesion = nil
            return RespuestaDeMijo(texto: Self.noEntendi)
        }
    }

    // MARK: Peticiones sin IA

    /// Hace lo que pidió y contesta con la frase que dejó la acción.
    private func cumplir(_ orden: Orden) async -> RespuestaDeMijo {
        switch orden {
        case .recordatorio(let paraQue, let hora, let minuto):
            _ = acciones.crearRecordatorio(paraQue: paraQue, hora: hora, minuto: minuto)
        case .recordatorioSinPeriodo(let paraQue, let hora, let minuto):
            pendiente = .periodo(paraQue: paraQue, hora: hora, minuto: minuto)
            return RespuestaDeMijo(texto: "¿A las \(hora) de la mañana o de la noche?")
        case .recordatorioSinHora:
            return RespuestaDeMijo(texto: "¿A qué hora se la recuerdo? Dígame, por ejemplo: recuérdame la pastilla de la presión a las nueve de la noche.")
        case .mensaje(let para, let texto):
            _ = await acciones.mandarWhatsApp(a: para, texto: texto)
        case .aviso(let texto):
            _ = await acciones.avisarFamilia(texto: texto)
        case .llamar(let familiar):
            _ = await acciones.llamar(a: familiar)
        case .pastillaTomada(let paraQue):
            _ = acciones.marcarTomada(paraQue: paraQue)
        case .pastillaDudosa(let paraQue):
            if let medicina = acciones.revisarToma(paraQue: paraQue) { pendiente = .toma(medicina) }
        case .consultarPastillas:
            _ = acciones.consultarMedicinas(paraQue: "")
        case .comida(let tipo, let yaComio):
            _ = acciones.registrarComida(TipoComida(rawValue: tipo) ?? .comida, yaComio: yaComio)
        case .abrirApp(let app):
            _ = acciones.abrirApp(app)
        case .appDesconocida:
            _ = acciones.abrirApp("")
        case .buscar(let texto):
            _ = acciones.buscarEnYouTube(texto)
        case .dondeEstoy:
            _ = await acciones.decirDireccion()
        }
        return hecho(o: Self.noEntendi)
    }

    /// La siguiente frase después de una pregunta de Mijo; nil si no la contesta.
    private func contestar(_ pendiente: Pendiente, con frase: String) -> RespuestaDeMijo? {
        let texto = EmergencyRouter.normalizar(frase)
        switch pendiente {
        case .periodo(let paraQue, let hora, let minuto):
            guard let tarde = ComandosDeVoz.esDeTarde(frase) else { return nil }
            _ = acciones.crearRecordatorio(paraQue: paraQue, hora: ComandosDeVoz.en24(hora, tarde: tarde), minuto: minuto)
        case .toma(let medicina):
            if texto.hasPrefix("no") || texto.contains("todavia") {
                return RespuestaDeMijo(texto: "Está bien. Cuando se la tome, me dice.")
            }
            guard texto.hasPrefix("si") || texto.hasPrefix("ya") || texto.contains("me la tome") else { return nil }
            acciones.marcarTomada(medicina)
            return RespuestaDeMijo(texto: "Muy bien, ya lo anoté. Su pastilla de \(medicina.paraQue) está tomada.")
        }
        return hecho(o: Self.noEntendi)
    }

    /// La respuesta con lo que dejó la última acción; `texto` solo se usa si ninguna dejó frase.
    private func hecho(o texto: String) -> RespuestaDeMijo {
        RespuestaDeMijo(texto: acciones.frase ?? texto, detalle: acciones.detalle,
                        etiquetas: acciones.etiquetas, accion: acciones.accion)
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
        // Carrera entre la IA y un reloj: gana quien termine primero.
        let carrera = Carrera()
        return try await withCheckedThrowingContinuation { continuacion in
            let tarea = Task {
                do {
                    let respuesta = try await sesion.respond(to: frase)
                    guard carrera.sigue() else { return }
                    continuacion.resume(returning: respuesta.content.trimmingCharacters(in: .whitespacesAndNewlines))
                } catch {
                    guard carrera.sigue() else { return }
                    continuacion.resume(throwing: error)
                }
            }
            Task {
                try? await Task.sleep(for: .seconds(Self.segundosParaPensar))
                guard carrera.sigue() else { return }
                tarea.cancel()
                continuacion.resume(throwing: TardoDemasiado())
            }
        }
    }

    /// Para que solo el primero en terminar entregue la respuesta.
    private final class Carrera {
        private var terminada = false
        /// true solo la primera vez que se pregunta.
        func sigue() -> Bool {
            defer { terminada = true }
            return !terminada
        }
    }

    private func nuevaSesion() -> LanguageModelSession {
        let ahora = Date.now.formatted(.dateTime.weekday(.wide).hour().minute().locale(Locale(identifier: "es_MX")))
        return LanguageModelSession(
            tools: [
                // Solo 3: con 10 la IA del teléfono las confundía (pruebas del 10 nov).
                // Lo demás (WhatsApp, apps, YouTube, avisos…) lo resuelve ComandosDeVoz.
                LlamarFamiliarTool(acciones: acciones),
                CrearRecordatorioMedicinaTool(acciones: acciones),
                ConsultarMedicinaTool(acciones: acciones),
            ],
            instructions: """
            Eres Mijo, el nieto virtual de \(nombre), una persona mayor que vive en México. \
            Siempre le hablas de usted (nunca de tú), con cariño y respeto, en español de México.
            Contesta en una o dos frases cortas y sencillas, sin listas ni símbolos, \
            porque tu respuesta se lee en voz alta.
            Ahora es \(ahora).
            Usa una herramienta solo cuando la persona pida claramente algo que esa herramienta hace: \
            llamar a alguien, guardar un recordatorio de pastilla o saber de sus pastillas.
            Si solo platica o no queda claro qué quiere, contesta amable y breve, sin usar herramientas.
            No ofrezcas hacer cosas que no puedes hacer, como cocinar, ir a un lugar o comprar algo.
            No inventes horarios ni datos: di solo lo que te regresen las herramientas.
            Si dice una hora sin decir si es de la mañana o de la noche, pregúntale.
            No des consejos médicos ni cambies dosis: para eso está su doctor.
            """
        )
    }
}
