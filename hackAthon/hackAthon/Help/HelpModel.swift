//
//  HelpModel.swift
//  hackAthon
//
//  Protocolo fijo de emergencia (sin IA):
//  1. Mijo pregunta "¿Está bien?" (en una caída: "¿Le duele algo?") y cuenta 30 segundos.
//  2. "Sí, estoy bien" (botón o voz) → se cierra, sin molestar a nadie.
//     En una caída, "No me duele" → avisa a la familia (sin urgencia) y
//     Mijo le dice paso a paso cómo levantarse.
//  3. "Necesito ayuda", "me duele", o no contesta → avisa a la familia por
//     ntfy con su dirección, Mijo se la dice en voz y le marca al familiar principal.
//  Si dijo "me siento mal" hablando con Mijo, se salta la pregunta.
//  4. Cuando logra levantarse, la familia recibe un segundo aviso: "ya se levantó".
//

import Foundation
import Observation
import SwiftData
import UIKit

enum FaseDeAyuda: Equatable {
    case preguntando
    case avisando
    /// Caída sin dolor: Mijo va leyendo los pasos. `paso` = el que está diciendo;
    /// igual a `HelpModel.pasosParaLevantarse.count` cuando ya terminó y espera respuesta.
    case levantandose(paso: Int)
    /// `enviado`: si ntfy recibió el aviso (puede fallar sin internet).
    case avisado(enviado: Bool)
    /// Se levantó con los pasos: pantalla de "¡Muy bien!" hasta que toque Terminar.
    case levantado
    /// Dijo que está bien: la pantalla se cierra.
    case bien
}

@Observable
final class HelpModel {
    static let segundosParaContestar = 30
    /// Si después de los pasos no contesta en este tiempo, se pide ayuda.
    static let segundosParaLevantarse = 60
    /// Lo que espera en cada paso a que diga "ya" antes de pasar solo al siguiente.
    static let segundosPorPaso = 15

    /// Pasos para levantarse después de una caída (sin dolor), uno por uno.
    static let pasosParaLevantarse = [
        "No se apure. Respire despacio.",
        "Gire de lado y doble las rodillas.",
        "Apoye las manos y las rodillas en el piso.",
        "Gatee despacio hasta una silla firme.",
        "Apóyese en la silla y suba un pie.",
        "Empújese despacio y siéntese a descansar.",
    ]
    /// Renglón gris debajo de cada paso (solo se lee en pantalla; Mijo dice el paso).
    static let detalleDePasos = [
        "Tómese su tiempo. No hay prisa.",
        "Hacia el lado que le sea más fácil.",
        "Quédese así hasta sentirse firme.",
        "También sirve la cama o un sillón que no se mueva.",
        "Las dos manos en el asiento y adelante su pierna más fuerte.",
        "Siéntese con calma. No camine todavía.",
    ]

    let voz = VoiceService()
    let nombre: String
    let motivo: Emergencia
    private(set) var fase = FaseDeAyuda.preguntando
    private(set) var segundos = HelpModel.segundosParaContestar
    let familiar: Familiar?
    let ficha: FichaMedica?
    /// Dónde está, para el aviso y para decirlo en voz. Llega unos segundos después.
    private(set) var ubicacion: Ubicacion?
    /// true cuando a la familia ya le llegó el aviso de la caída (rama "no me duele").
    private(set) var familiaAvisada = false

    @ObservationIgnored private let acciones: MijoActions
    /// Lo que dijo hablando con Mijo ("me caí"); nil si tocó el botón Ayuda.
    @ObservationIgnored private let frase: String?
    @ObservationIgnored private var cerrada = false
    /// true cuando pidió otro paso (botón o voz): el ciclo de pasos deja de esperar.
    @ObservationIgnored private var saltar = false
    /// Para el aviso: no se pudo levantar después de los pasos.
    @ObservationIgnored private var noSePudoLevantar = false
    /// El GPS se empieza a leer desde que abre la pantalla, para tenerlo listo al avisar.
    @ObservationIgnored private var buscandoUbicacion: Task<Ubicacion?, Never>?

    init(context: ModelContext, nombre: String, motivo: Emergencia, frase: String? = nil) {
        acciones = MijoActions(context: context)
        self.nombre = nombre
        self.motivo = motivo
        self.frase = frase
        familiar = acciones.familiarPrincipal()
        ficha = acciones.fichaMedica()
    }

    /// En una caída se pregunta "¿Le duele algo?" en vez de "¿Está bien?".
    var preguntaDolor: Bool { motivo == .caida }

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
        buscandoUbicacion = Task { await LocationService.ubicacionActual(segundos: 6) }
        // "Me siento mal" dicho a Mijo ya es la respuesta; en una caída sí se pregunta si le duele.
        if frase != nil, !preguntaDolor {
            await pedirAyuda()
            return
        }
        let pregunta = preguntaDolor ? "¿le duele algo?" : "¿está bien?"
        await voz.hablar("\(nombre), \(pregunta) Toque un botón o dígame.")
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
        let dicho = EmergencyRouter.normalizar(texto)
        let palabras = dicho.split(separator: " ")
        if case .levantandose = fase {
            revisarLevantada(dicho, palabras)
            return
        }
        guard fase == .preguntando else { return }
        if preguntaDolor {
            revisarDolor(dicho, palabras)
            return
        }
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

    /// Respuesta a "¿Le duele algo?". "No me puedo levantar" y "no me duele" llevan "no": van primero.
    private func revisarDolor(_ dicho: String, _ palabras: [Substring]) {
        if dicho.contains("no puedo") || dicho.contains("no me puedo") {
            Task { await pedirAyuda() }
        } else if dicho.contains("no me duele") || dicho.contains("nada") || dicho.contains("estoy bien")
                    || palabras.first == "no" {
            Task { await noMeDuele() }
        } else if dicho.contains("duele") || palabras.first == "si" || dicho.contains("ayuda")
                    || dicho.contains("mucho") || EmergencyRouter.detectar(dicho) == .malestar {
            Task { await pedirAyuda() }
        }
    }

    /// Mientras lee los pasos: "ya" → siguiente, "repite" → otra vez. Al final, "¿Ya se pudo levantar?".
    private func revisarLevantada(_ dicho: String, _ palabras: [Substring]) {
        guard case .levantandose(let paso) = fase, !saltar else { return }
        let alFinal = paso >= Self.pasosParaLevantarse.count
        if dicho.contains("no puedo") || dicho.contains("no me puedo") || dicho.contains("ayuda")
            || dicho.contains("duele") || (alFinal && palabras.first == "no") {
            Task { await noPuedoLevantarme() }
        } else if dicho.contains("me levante") || (alFinal && (palabras.first == "si" || palabras.first == "ya"
                    || dicho.contains("listo") || dicho.contains("estoy bien"))) {
            Task { await yaMeLevante() }
        } else if dicho.contains("repite") || dicho.contains("otra vez") || dicho.contains("no entendi") {
            repetirPaso()
        } else if palabras.first == "ya" || palabras.first == "si" || dicho.contains("listo")
                    || dicho.contains("siguiente") {
            siguientePaso()
        }
    }

    func estoyBien() async {
        guard fase == .preguntando else { return }
        voz.terminarDeEscuchar()
        fase = .avisando // detiene la cuenta mientras Mijo habla
        await voz.hablar("Qué bueno. Aquí sigo por si me necesita.")
        fase = .bien
    }

    // MARK: Caída sin dolor

    /// Avisa a la familia sin urgencia y Mijo lee los pasos para levantarse.
    func noMeDuele() async {
        guard fase == .preguntando else { return }
        voz.terminarDeEscuchar()
        fase = .levantandose(paso: 0)
        Haptics.success()
        Task {
            // El aviso va en paralelo: Mijo no se queda callado esperando el internet.
            guard let datos = acciones.datosParaAvisar() else { return }
            let ubicacion = await esperarUbicacion()
            var mensaje = "Dice que no le duele. Mijo le está ayudando a levantarse."
            if let direccion = ubicacion?.direccion { mensaje += " Está en: \(direccion)." }
            familiaAvisada = await NtfyService.avisar(tema: datos.tema, titulo: "\(datos.nombre) se cayó", mensaje: mensaje,
                                                      prioridad: .alta, etiquetas: ["warning"], mapa: ubicacion?.mapa)
        }
        await voz.hablar("Qué bueno que no le duele. Le aviso a su familia y vamos a levantarnos despacio. Cuando termine cada paso, dígame: ya.")
        // Un paso a la vez: lo dice, escucha, y si no contesta pasa solo al siguiente.
        // Después del último pregunta si ya se levantó; si no contesta, pide ayuda.
        while !cerrada, case .levantandose(let paso) = fase {
            saltar = false
            voz.terminarDeEscuchar() // que no se escuche a sí mismo
            let alFinal = paso >= Self.pasosParaLevantarse.count
            await voz.hablar(alFinal ? "¿Ya se pudo levantar? Si no puede, dígame y le pido ayuda."
                                     : Self.pasosParaLevantarse[paso])
            if saltar { continue }
            guard !cerrada, case .levantandose = fase else { return }
            if await voz.pedirPermisos() { try? voz.empezarAEscuchar() }
            let espera = alFinal ? Self.segundosParaLevantarse : Self.segundosPorPaso
            for _ in 0..<(espera * 4) {
                try? await Task.sleep(for: .milliseconds(250))
                guard !saltar, !cerrada, case .levantandose = fase else { break }
            }
            guard !cerrada, case .levantandose(let ahora) = fase else { return }
            if saltar || ahora != paso { continue }
            if alFinal {
                await noPuedoLevantarme()
                return
            }
            fase = .levantandose(paso: paso + 1)
        }
    }

    /// Botones ⏮ ⟲ ⏭ y "ya" / "repite" por voz.
    func siguientePaso() {
        if case .levantandose(let paso) = fase { irAlPaso(paso + 1) }
    }

    func pasoAnterior() {
        if case .levantandose(let paso) = fase { irAlPaso(paso - 1) }
    }

    func repetirPaso() {
        if case .levantandose(let paso) = fase { irAlPaso(paso) }
    }

    private func irAlPaso(_ paso: Int) {
        saltar = true
        voz.terminarDeEscuchar()
        voz.callar()
        fase = .levantandose(paso: min(max(paso, 0), Self.pasosParaLevantarse.count))
    }

    func yaMeLevante() async {
        guard case .levantandose = fase else { return }
        voz.terminarDeEscuchar()
        voz.callar()
        fase = .levantado
        Haptics.success()
        Task {
            // Segundo aviso, para que la familia se quede tranquila.
            guard let datos = acciones.datosParaAvisar() else { return }
            await NtfyService.avisar(tema: datos.tema, titulo: "\(datos.nombre) ya se levantó",
                                     mensaje: "Siguió los pasos con Mijo y dice que está bien. Llámele en un rato para saber cómo sigue.",
                                     prioridad: .normal, etiquetas: ["white_check_mark"])
        }
        await voz.hablar("Muy bien. Descanse un rato antes de caminar. Ya le avisé a su familia que está bien.")
    }

    func noPuedoLevantarme() async {
        guard case .levantandose = fase else { return }
        noSePudoLevantar = true
        voz.terminarDeEscuchar()
        voz.callar()
        fase = .preguntando
        await pedirAyuda()
    }

    // MARK: Pedir ayuda

    func pedirAyuda() async {
        guard fase == .preguntando else { return }
        voz.terminarDeEscuchar()
        fase = .avisando

        var enviado = false
        let ubicacion = await esperarUbicacion()
        if let datos = acciones.datosParaAvisar() {
            let titulo = switch motivo {
            case .caida: "\(datos.nombre) se cayó"
            case .malestar: "\(datos.nombre) se siente mal"
            case .ayuda: "\(datos.nombre) necesita ayuda"
            }
            var mensaje = if noSePudoLevantar { "Dice que no le duele, pero no se puede levantar." }
                else if let frase { "Le dijo a Mijo: “\(frase)”." }
                else if segundos == 0 { "No contestó en \(Self.segundosParaContestar) segundos." }
                else { "Tocó el botón de ayuda." }
            if let direccion = ubicacion?.direccion { mensaje += " Está en: \(direccion)." }
            if let familiar { mensaje += " Mijo le está marcando a \(familiar.nombre)." }
            enviado = await NtfyService.avisar(tema: datos.tema, titulo: titulo, mensaje: mensaje,
                                               prioridad: .urgente, etiquetas: ["rotating_light"],
                                               mapa: ubicacion?.mapa)
        }
        guard !cerrada else { return }
        fase = .avisado(enviado: enviado)
        if enviado { Haptics.success() }

        let aviso = enviado ? "Ya le avisé a su familia." : ""
        // La dirección en voz, por si tiene que dársela al 911 o a quien conteste.
        let donde = ubicacion?.direccionCorta.map { "Usted está en \($0)." } ?? ""
        if let familiar {
            await voz.hablar("Aquí estoy con usted. \(aviso) \(donde) Ahorita le marco a \(familiar.nombre).")
            if !cerrada { llamar(familiar) }
        } else {
            await voz.hablar("Aquí estoy con usted. \(aviso) \(donde) Si es urgente, toque Llamar al 911.")
        }
    }

    /// iOS siempre pide un toque en "Llamar": ninguna app puede marcar sola.
    func llamar(_ familiar: Familiar) {
        abrir("tel://\(familiar.telefono.filter(\.isNumber))")
    }

    func llamarAl911() {
        abrir("tel://911")
    }

    /// La ubicación que se empezó a buscar al abrir la pantalla (máximo 6 s).
    private func esperarUbicacion() async -> Ubicacion? {
        if ubicacion == nil { ubicacion = await buscandoUbicacion?.value }
        return ubicacion
    }

    func cerrar() {
        cerrada = true
        buscandoUbicacion?.cancel()
        voz.terminarDeEscuchar()
        voz.callar()
    }

    private func abrir(_ direccion: String) {
        guard let url = URL(string: direccion) else { return }
        UIApplication.shared.open(url)
    }
}
