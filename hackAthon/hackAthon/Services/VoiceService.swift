//
//  VoiceService.swift
//  hackAthon
//
//  La voz de Mijo: habla (AVSpeechSynthesizer, español de México) y
//  escucha (Speech, en el teléfono cuando se puede).
//  Lo usan la conversación con Mijo y el registro por voz:
//  preguntar → escuchar → confirmar.
//

import AVFoundation
import Observation
import Speech

enum ErrorDeVoz: Error {
    /// No hay reconocimiento de voz en español o no hay micrófono.
    case noDisponible
}

@Observable
final class VoiceService {
    /// Lo que se va entendiendo mientras la persona habla.
    private(set) var textoEscuchado = ""
    /// Qué tan fuerte se oye, de 0 a 1. Mueve las barras de la pantalla.
    private(set) var nivel: Double = 0
    private(set) var escuchando = false
    private(set) var hablando = false

    @ObservationIgnored private let sintetizador = AVSpeechSynthesizer()
    @ObservationIgnored private let delegado = DelegadoDeVoz()
    @ObservationIgnored private let reconocedor = SFSpeechRecognizer(locale: Locale(identifier: "es-MX"))
    @ObservationIgnored private let motor = AVAudioEngine()
    @ObservationIgnored private var peticion: SFSpeechAudioBufferRecognitionRequest?
    @ObservationIgnored private var tarea: SFSpeechRecognitionTask?
    /// Cambia cada vez que se empieza a escuchar: así se ignoran avisos viejos.
    @ObservationIgnored private var sesion = 0
    @ObservationIgnored private var fraseActual: ObjectIdentifier?
    @ObservationIgnored private var alTerminarDeHablar: CheckedContinuation<Void, Never>?
    /// true cuando la frase actual ya empezó a sonar (para detectar si la Voz personal se quedó muda).
    @ObservationIgnored private var empezoASonar = false

    init() {
        sintetizador.delegate = delegado
        delegado.alTerminar = { [weak self] frase in self?.terminoDeHablar(frase) }
        delegado.alEmpezar = { [weak self] frase in
            if frase == self?.fraseActual { self?.empezoASonar = true }
        }
    }

    // MARK: Permisos

    /// Pide micrófono y reconocimiento de voz. true si dieron los dos.
    func pedirPermisos() async -> Bool {
        // Si al proyecto le faltan los textos de permiso, iOS cierra la app al pedirlos.
        let textos = ["NSMicrophoneUsageDescription", "NSSpeechRecognitionUsageDescription"]
        guard textos.allSatisfy({ Bundle.main.object(forInfoDictionaryKey: $0) != nil }) else { return false }
        guard await Self.pedirPermisoDeVoz() else { return false }
        return await AVAudioApplication.requestRecordPermission()
    }

    // MARK: Hablar

    /// Dice la frase y regresa cuando termina (o cuando lo callan).
    func hablar(_ texto: String) async {
        callar()
        prepararAudio()
        let frase = Self.frase(texto)
        let conVozPersonal = frase.voice?.voiceTraits.contains(.isPersonalVoice) == true
        fraseActual = ObjectIdentifier(frase)
        empezoASonar = false
        hablando = true
        if conVozPersonal {
            // Respaldo: si la Voz personal no empieza a sonar en 3 s, se calla y se usa la de Apple.
            let estaFrase = fraseActual
            Task {
                try? await Task.sleep(for: .seconds(3))
                guard fraseActual == estaFrase, !empezoASonar else { return }
                print("🗣️ La Voz personal no sonó: Mijo regresa a la voz de Apple")
                Self.vozPersonalFalla = true
                sintetizador.stopSpeaking(at: .immediate)
            }
        }
        await withCheckedContinuation { continuacion in
            alTerminarDeHablar = continuacion
            sintetizador.speak(frase)
        }
        // Si la Voz personal falló, se repite la frase con la voz de Apple.
        if conVozPersonal, Self.vozPersonalFalla, !empezoASonar {
            await hablar(texto)
        }
    }

    func callar() {
        if sintetizador.isSpeaking { sintetizador.stopSpeaking(at: .immediate) }
        soltarEspera()
    }

    private func terminoDeHablar(_ frase: ObjectIdentifier) {
        guard frase == fraseActual else { return }
        soltarEspera()
    }

    private func soltarEspera() {
        fraseActual = nil
        hablando = false
        alTerminarDeHablar?.resume()
        alTerminarDeHablar = nil
    }

    // MARK: Escuchar

    func empezarAEscuchar() throws {
        callar()
        apagarMicrofono()
        guard let reconocedor, reconocedor.isAvailable else { throw ErrorDeVoz.noDisponible }
        prepararAudio()
        textoEscuchado = ""
        sesion += 1
        let estaSesion = sesion

        let peticion = SFSpeechAudioBufferRecognitionRequest()
        peticion.shouldReportPartialResults = true
        // En el teléfono: nada de lo que dice sale a internet.
        peticion.requiresOnDeviceRecognition = reconocedor.supportsOnDeviceRecognition
        self.peticion = peticion

        tarea = Self.reconocer(reconocedor, peticion) { [weak self] texto in
            guard let self, self.sesion == estaSesion, self.escuchando else { return }
            self.textoEscuchado = texto
        }
        try Self.conectarMicrofono(motor, a: peticion) { [weak self] nivel in
            guard let self, self.sesion == estaSesion, self.escuchando else { return }
            self.nivel = nivel
        }
        motor.prepare()
        try motor.start()
        escuchando = true
    }

    /// Deja de escuchar y regresa lo que entendió.
    @discardableResult
    func terminarDeEscuchar() -> String {
        apagarMicrofono()
        return textoEscuchado
    }

    private func apagarMicrofono() {
        escuchando = false
        nivel = 0
        if motor.isRunning { motor.stop() }
        motor.inputNode.removeTap(onBus: 0)
        peticion?.endAudio()
        tarea?.finish()
        peticion = nil
        tarea = nil
    }

    private func prepararAudio() {
        let audio = AVAudioSession.sharedInstance()
        try? audio.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .duckOthers])
        try? audio.setActive(true)
    }

    /// La frase con la voz, velocidad y tono de Mijo. También la usan las notificaciones.
    /// `vozPersonal: false` para grabar audios (notificaciones): ahí solo se usa la voz de Apple.
    static func frase(_ texto: String, vozPersonal: Bool = true) -> AVSpeechUtterance {
        let frase = AVSpeechUtterance(string: texto)
        if vozPersonal, let personal = Self.buscarVozPersonal() {
            // La Voz personal ya suena como la persona: sin cambiarle velocidad ni tono.
            frase.voice = personal
            return frase
        }
        frase.voice = mejorVozDeApple
        frase.rate = 0.48 // apenas más lento que lo normal (0.5): claro sin sonar arrastrado
        frase.pitchMultiplier = 1.05 // un poquito más joven
        return frase
    }

    /// Pide permiso para usar la Voz personal (la que la persona grabó en Ajustes →
    /// Accesibilidad → Voz personal). iOS lo pregunta una sola vez.
    static func pedirVozPersonal() async {
        guard AVSpeechSynthesizer.personalVoiceAuthorizationStatus == .notDetermined else { return }
        _ = await AVSpeechSynthesizer.requestPersonalVoiceAuthorization()
    }

    /// true si la Voz personal se quedó muda una vez: ya no se intenta hasta abrir la app otra vez.
    private static var vozPersonalFalla = false
    private static var yaLoDijo = false

    /// La Voz personal en español (o la que haya) si dio permiso; nil si no.
    private static func buscarVozPersonal() -> AVSpeechSynthesisVoice? {
        guard !vozPersonalFalla else { return nil }
        let estado = AVSpeechSynthesizer.personalVoiceAuthorizationStatus
        let personales = AVSpeechSynthesisVoice.speechVoices().filter { $0.voiceTraits.contains(.isPersonalVoice) }
        if !yaLoDijo {
            yaLoDijo = true
            // Para revisar en la consola de Xcode qué ve Mijo.
            print("🗣️ Voz personal · permiso: \(estado.rawValue) (3 = permitido) · voces: "
                  + personales.map { "\($0.name) [\($0.language)] \($0.identifier)" }.joined(separator: ", "))
        }
        guard estado == .authorized else { return nil }
        // Solo en español: una Voz personal de otro idioma (p. ej. zh-CN) se queda muda leyendo español.
        return personales.first { $0.language.hasPrefix("es") }
    }

    /// La voz más natural en español de México que tenga el teléfono.
    /// Orden: Premium → Mejorada → normal; a igual calidad, voz de hombre (Mijo es nieto).
    /// Se descartan las voces "de efecto" (Grandma, Rocko, Shelley…): suenan a robot.
    private static let mejorVozDeApple: AVSpeechSynthesisVoice? = {
        let voces = AVSpeechSynthesisVoice.speechVoices().filter {
            $0.language == "es-MX" && $0.identifier.hasPrefix("com.apple.voice.")
        }
        func puntos(_ voz: AVSpeechSynthesisVoice) -> Int {
            voz.quality.rawValue * 10 + (voz.gender == .male ? 1 : 0)
        }
        return voces.max { puntos($0) < puntos($1) } ?? AVSpeechSynthesisVoice(language: "es-MX")
    }()

    // MARK: Fuera del hilo principal
    // El sistema llama a estos bloques desde sus propios hilos (audio, Speech).
    // Por eso van en funciones `nonisolated`: no tocan la pantalla y solo
    // mandan el resultado al hilo principal con `Task { @MainActor in … }`.

    nonisolated private static func pedirPermisoDeVoz() async -> Bool {
        await withCheckedContinuation { continuacion in
            SFSpeechRecognizer.requestAuthorization { estado in
                continuacion.resume(returning: estado == .authorized)
            }
        }
    }

    nonisolated private static func reconocer(
        _ reconocedor: SFSpeechRecognizer,
        _ peticion: SFSpeechAudioBufferRecognitionRequest,
        alOir: @escaping @MainActor @Sendable (String) -> Void
    ) -> SFSpeechRecognitionTask {
        reconocedor.recognitionTask(with: peticion) { resultado, _ in
            guard let texto = resultado?.bestTranscription.formattedString else { return }
            Task { @MainActor in alOir(texto) }
        }
    }

    nonisolated private static func conectarMicrofono(
        _ motor: AVAudioEngine,
        a peticion: SFSpeechAudioBufferRecognitionRequest,
        alMedir: @escaping @MainActor @Sendable (Double) -> Void
    ) throws {
        let entrada = motor.inputNode
        let formato = entrada.outputFormat(forBus: 0)
        guard formato.sampleRate > 0 else { throw ErrorDeVoz.noDisponible }
        entrada.installTap(onBus: 0, bufferSize: 1024, format: formato) { buffer, _ in
            peticion.append(buffer)
            let nivel = volumen(de: buffer)
            Task { @MainActor in alMedir(nivel) }
        }
    }

    /// Volumen del pedazo de audio, de 0 (silencio) a 1 (fuerte).
    nonisolated private static func volumen(de buffer: AVAudioPCMBuffer) -> Double {
        guard let canal = buffer.floatChannelData?[0], buffer.frameLength > 0 else { return 0 }
        let n = Int(buffer.frameLength)
        var suma: Float = 0
        for i in 0..<n { suma += canal[i] * canal[i] }
        let decibeles = 10 * log10(Double(suma / Float(n)) + 1e-10)
        return min(max((decibeles + 50) / 40, 0), 1) // de -50 dB a -10 dB
    }
}

/// AVSpeechSynthesizer avisa aquí cuando termina de decir una frase.
private final class DelegadoDeVoz: NSObject, AVSpeechSynthesizerDelegate {
    var alTerminar: (@MainActor (ObjectIdentifier) -> Void)?
    var alEmpezar: (@MainActor (ObjectIdentifier) -> Void)?

    nonisolated func speechSynthesizer(_ s: AVSpeechSynthesizer, didStart frase: AVSpeechUtterance) {
        let id = ObjectIdentifier(frase)
        Task { @MainActor in self.alEmpezar?(id) }
    }

    nonisolated func speechSynthesizer(_ s: AVSpeechSynthesizer, didFinish frase: AVSpeechUtterance) {
        avisar(ObjectIdentifier(frase))
    }

    nonisolated func speechSynthesizer(_ s: AVSpeechSynthesizer, didCancel frase: AVSpeechUtterance) {
        avisar(ObjectIdentifier(frase))
    }

    nonisolated private func avisar(_ frase: ObjectIdentifier) {
        Task { @MainActor in self.alTerminar?(frase) }
    }
}
