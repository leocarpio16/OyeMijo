//
//  OnboardingModel.swift
//  hackAthon
//
//  Registro por voz (PRD F6), versión corta. Sin cuentas ni contraseñas:
//  el perfil vive en el teléfono.
//  Bienvenida → 1 Nombre → 2 Persona de confianza → 3 Conectar a la familia
//  (QR del tema de ntfy) → 4 Permisos → ¡Listo!
//

import AVFoundation
import Foundation
import Observation
import Speech
import SwiftData
import UserNotifications

enum PasoDeRegistro: Int, CaseIterable {
    case bienvenida, nombre, contacto, conectar, permisos, listo

    /// Pasos numerados ("Paso 1 de 4"): sin contar Bienvenida ni ¡Listo!
    static let total = 4
    var numero: Int { rawValue }
}

/// La persona de confianza elegida de los contactos.
struct PersonaDeConfianza {
    var nombre: String
    var telefono: String
}

@Observable
final class OnboardingModel {
    let voz = VoiceService()
    private(set) var paso = PasoDeRegistro.bienvenida
    var nombre = ""
    var persona: PersonaDeConfianza?
    private(set) var microfonoListo = false
    private(set) var avisosListos = false
    /// Tema de ntfy: corto para poder escribirlo, largo para que nadie lo adivine.
    let tema = OnboardingModel.nuevoTema()

    // MARK: Avanzar

    func siguiente() {
        guard let siguiente = PasoDeRegistro(rawValue: paso.rawValue + 1) else { return }
        ir(a: siguiente)
    }

    func anterior() {
        guard let anterior = PasoDeRegistro(rawValue: paso.rawValue - 1) else { return }
        ir(a: anterior)
    }

    private func ir(a nuevo: PasoDeRegistro) {
        voz.terminarDeEscuchar()
        paso = nuevo
        Task { await decirPregunta() }
    }

    /// Lo que dice Mijo al llegar a cada paso (también con el botón de la bocina).
    func decirPregunta() async {
        await voz.hablar(pregunta)
    }

    var pregunta: String {
        switch paso {
        case .bienvenida: "Hola. Soy Mijo, su nieto en el teléfono. Solo hábleme y yo le ayudo."
        case .nombre: "¿Cómo le gusta que le diga? Dígamelo o escríbalo."
        case .contacto: "¿A quién le aviso si me necesita? Elija a su persona de confianza."
        case .conectar: "Ahora \(persona?.nombre ?? "su familiar") escanea este código con su celular."
        case .permisos: "Necesito dos permisos para escucharle y cuidarle. Toque Permitir todo."
        case .listo: "¡Listo, \(nombre)! Ya puede hablarme cuando quiera."
        }
    }

    // MARK: Nombre por voz

    func escucharNombre() async {
        if voz.escuchando {
            terminarNombre()
            return
        }
        guard await voz.pedirPermisos() else { return }
        try? voz.empezarAEscuchar()
    }

    /// "Me llamo María" → "María"; "dígame Doña Mari" → "Doña Mari".
    func terminarNombre() {
        let dicho = voz.terminarDeEscuchar()
        guard !dicho.isEmpty else { return }
        nombre = Self.limpiarNombre(dicho)
        Task { await voz.hablar("Le voy a decir \(nombre). Si está bien, toque Siguiente.") }
    }

    static func limpiarNombre(_ dicho: String) -> String {
        var texto = dicho.trimmingCharacters(in: .whitespacesAndNewlines.union(.punctuationCharacters))
        let inicios = ["me llamo", "mi nombre es", "me dicen", "dígame", "digame", "dime",
                       "llámeme", "llameme", "llámame", "llamame", "soy", "yo soy", "pues"]
        var cambio = true
        while cambio {
            cambio = false
            for inicio in inicios where texto.lowercased().hasPrefix(inicio + " ") {
                texto = String(texto.dropFirst(inicio.count + 1))
                cambio = true
            }
        }
        return texto.split(separator: " ")
            .map { $0.prefix(1).uppercased() + $0.dropFirst() }
            .joined(separator: " ")
    }

    // MARK: Permisos

    func revisarPermisos() async {
        microfonoListo = AVAudioApplication.shared.recordPermission == .granted
            && SFSpeechRecognizer.authorizationStatus() == .authorized
        avisosListos = await UNUserNotificationCenter.current().notificationSettings().authorizationStatus == .authorized
    }

    func permitirMicrofono() async {
        _ = await voz.pedirPermisos()
        await revisarPermisos()
    }

    func permitirAvisos() async {
        _ = await NotificationService.pedirPermiso()
        await revisarPermisos()
    }

    func permitirTodo() async {
        if !microfonoListo { await permitirMicrofono() }
        if !avisosListos { await permitirAvisos() }
        siguiente()
    }

    // MARK: Conectar

    /// Primer aviso por ntfy: así la familia ve que ya quedó conectada.
    func probarConexion() async {
        await NtfyService.avisar(tema: tema,
                                 titulo: "Mijo ya cuida a \(nombre)",
                                 mensaje: "Aquí le voy a avisar si necesita ayuda o si no confirma sus pastillas.",
                                 prioridad: .normal, etiquetas: ["wave"])
    }

    // MARK: Guardar

    /// Crea el perfil. Los horarios de comida son los más comunes; la familia los cambia después.
    func guardar(en context: ModelContext) async {
        voz.callar()
        context.insert(Ajustes(comoLlamarla: nombre,
                               desayuno: Horario(hora: 8, minuto: 30),
                               comida: Horario(hora: 14, minuto: 30),
                               cena: Horario(hora: 20, minuto: 0),
                               temaNtfy: tema))
        if let persona {
            context.insert(Familiar(nombre: persona.nombre, parentesco: "",
                                    telefono: persona.telefono, esPrincipal: true))
        }
        try? context.save()
        await NotificationService.reprogramar(context)
    }

    /// "mijo-k3f9-x2qa-7mbd": 12 letras y números al azar.
    private static func nuevoTema() -> String {
        let letras = Array("abcdefghjkmnpqrstuvwxyz23456789")
        let grupo = { String((0..<4).map { _ in letras.randomElement()! }) }
        return "mijo-\(grupo())-\(grupo())-\(grupo())"
    }
}
