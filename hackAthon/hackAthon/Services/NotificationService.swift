//
//  NotificationService.swift
//  hackAthon
//
//  "Mijo pregunta por ti" (PRD F1 y F2): notificaciones locales a la hora de
//  cada pastilla y comida, con la voz de Mijo como sonido y botones que se
//  contestan sin abrir la app:
//    Pastilla → [Ya me la tomé] [Más tarde]
//    Comida   → [Sí] [Todavía no]
//  "Más tarde" / "Todavía no" vuelven a preguntar en 30 minutos.
//

import Foundation
import SwiftData
import UserNotifications

enum NotificationService {

    enum Accion {
        static let tomada = "TOMADA"
        static let masTarde = "MAS_TARDE"
        static let comio = "COMIO"
        static let todaviaNo = "TODAVIA_NO"
    }

    private enum Categoria {
        static let medicina = "MEDICINA"
        static let comida = "COMIDA"
    }

    /// Todas las notificaciones de Mijo empiezan así; sirve para borrarlas y reprogramarlas.
    private static let prefijo = "mijo."
    private static let minutosParaVolverAPreguntar = 30
    private static var centro: UNUserNotificationCenter { .current() }

    // MARK: Preparar

    /// Registra los botones de cada tipo de notificación. Se llama al abrir la app.
    static func configurar() {
        let botones = { (id: String, titulo: String) in
            UNNotificationAction(identifier: id, title: titulo, options: [])
        }
        centro.setNotificationCategories([
            UNNotificationCategory(identifier: Categoria.medicina,
                                   actions: [botones(Accion.tomada, "Ya me la tomé"),
                                             botones(Accion.masTarde, "Más tarde")],
                                   intentIdentifiers: []),
            UNNotificationCategory(identifier: Categoria.comida,
                                   actions: [botones(Accion.comio, "Sí"),
                                             botones(Accion.todaviaNo, "Todavía no")],
                                   intentIdentifiers: []),
        ])
    }

    static func pedirPermiso() async -> Bool {
        (try? await centro.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
    }

    // MARK: Programar

    /// Borra y vuelve a crear las preguntas diarias. Se llama al abrir la app
    /// y cada vez que cambia una medicina.
    static func reprogramar(_ context: ModelContext) async {
        guard let ajustes = try? context.fetch(FetchDescriptor<Ajustes>()).first else { return }
        let viejas = await centro.pendingNotificationRequests()
            .map(\.identifier)
            .filter { $0.hasPrefix(prefijo + "diaria.") }
        centro.removePendingNotificationRequests(withIdentifiers: viejas)

        let nombre = ajustes.comoLlamarla
        for medicina in (try? context.fetch(FetchDescriptor<Medicina>())) ?? [] {
            for horario in medicina.horarios {
                await programar(preguntaDePastilla(medicina, nombre: nombre),
                                id: "diaria.med.\(medicina.nombre).\(horario.minutosDelDia)",
                                categoria: Categoria.medicina,
                                datos: datos(medicina: medicina, horario: horario, nombre: nombre),
                                cuando: diaria(horario))
            }
        }
        let comidas: [(TipoComida, Horario)] = [(.desayuno, ajustes.desayuno),
                                                (.comida, ajustes.comida),
                                                (.cena, ajustes.cena)]
        for (tipo, horario) in comidas {
            await programar(preguntaDeComida(tipo, nombre: nombre),
                            id: "diaria.comida.\(tipo.rawValue)",
                            categoria: Categoria.comida,
                            datos: ["comida": tipo.rawValue, "nombre": nombre],
                            cuando: diaria(horario))
        }
    }

    /// Para la demo: la pregunta de la pastilla que toca, en 5 segundos.
    static func probarAhora(_ context: ModelContext) async {
        guard let ajustes = try? context.fetch(FetchDescriptor<Ajustes>()).first,
              let medicina = try? context.fetch(FetchDescriptor<Medicina>()).first(where: { !$0.horarios.isEmpty }),
              let horario = medicina.horarioPorConfirmar() ?? medicina.horarios.sorted().first else { return }
        await programar(preguntaDePastilla(medicina, nombre: ajustes.comoLlamarla),
                        id: "prueba.\(UUID().uuidString)",
                        categoria: Categoria.medicina,
                        datos: datos(medicina: medicina, horario: horario, nombre: ajustes.comoLlamarla),
                        cuando: UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false))
    }

    // MARK: Respuestas

    /// Lo que contestó en la notificación. Se copia a tipos simples para poder
    /// pasarlo del hilo de la notificación al hilo principal.
    struct Respuesta: Sendable {
        let accion: String
        let medicina: String?
        let minutoDelDia: Int?
        let comida: String?
        let nombre: String?

        nonisolated init(_ respuesta: UNNotificationResponse) {
            let datos = respuesta.notification.request.content.userInfo
            accion = respuesta.actionIdentifier
            medicina = datos["medicina"] as? String
            minutoDelDia = datos["minutoDelDia"] as? Int
            comida = datos["comida"] as? String
            nombre = datos["nombre"] as? String
        }
    }

    /// Guarda la respuesta. Funciona aunque la app esté cerrada.
    static func atender(_ respuesta: Respuesta) async {
        let context = Persistence.container.mainContext
        let nombre = respuesta.nombre ?? ""

        if let nombreMedicina = respuesta.medicina, let minuto = respuesta.minutoDelDia,
           let medicina = try? context.fetch(FetchDescriptor<Medicina>()).first(where: { $0.nombre == nombreMedicina }) {
            let horario = Horario(hora: minuto / 60, minuto: minuto % 60)
            switch respuesta.accion {
            case Accion.tomada:
                context.insert(Toma(medicina: medicina, programada: horario.fechaDeHoy,
                                    estado: .tomada, respondida: .now))
                await FamilyAlerts.avisarTomada(medicina, context: context)
            case Accion.masTarde:
                context.insert(Toma(medicina: medicina, programada: horario.fechaDeHoy,
                                    estado: .pospuesta, respondida: .now))
                await programar("\(nombre), ¿ya se tomó su \(medicina.nombreParaMostrar.lowercased())?",
                                id: "tarde.med.\(medicina.nombre).\(minuto)",
                                categoria: Categoria.medicina,
                                datos: datos(medicina: medicina, horario: horario, nombre: nombre),
                                cuando: enUnRato())
            default:
                break // tocó la notificación: solo se abre la app
            }
        } else if let comida = respuesta.comida, let tipo = TipoComida(rawValue: comida) {
            switch respuesta.accion {
            case Accion.comio:
                context.insert(Comida(tipo: tipo, yaComio: true))
            case Accion.todaviaNo:
                context.insert(Comida(tipo: tipo, yaComio: false))
                await programar(preguntaDeComida(tipo, nombre: nombre),
                                id: "tarde.comida.\(tipo.rawValue)",
                                categoria: Categoria.comida,
                                datos: ["comida": tipo.rawValue, "nombre": nombre],
                                cuando: enUnRato())
            default:
                break
            }
        }
        try? context.save()
    }

    // MARK: Ayudas

    private static func preguntaDePastilla(_ medicina: Medicina, nombre: String) -> String {
        "\(nombre), ya es hora de su \(medicina.nombreParaMostrar.lowercased()). ¿Ya se la tomó?"
    }

    private static func preguntaDeComida(_ tipo: TipoComida, nombre: String) -> String {
        switch tipo {
        case .desayuno: "\(nombre), ¿ya desayunó?"
        case .comida: "\(nombre), ¿ya comió?"
        case .cena: "\(nombre), ¿ya cenó?"
        }
    }

    private static func datos(medicina: Medicina, horario: Horario, nombre: String) -> [String: Any] {
        ["medicina": medicina.nombre, "minutoDelDia": horario.minutosDelDia, "nombre": nombre]
    }

    private static func diaria(_ horario: Horario) -> UNCalendarNotificationTrigger {
        UNCalendarNotificationTrigger(dateMatching: DateComponents(hour: horario.hora, minute: horario.minuto),
                                      repeats: true)
    }

    private static func enUnRato() -> UNTimeIntervalNotificationTrigger {
        UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(minutosParaVolverAPreguntar * 60),
                                          repeats: false)
    }

    private static func programar(_ texto: String, id: String, categoria: String,
                                  datos: [String: Any], cuando: UNNotificationTrigger) async {
        let contenido = UNMutableNotificationContent()
        contenido.title = "Mijo"
        contenido.body = texto
        contenido.categoryIdentifier = categoria
        contenido.userInfo = datos
        contenido.sound = await VoiceRecorder.sonido(para: texto)
        let peticion = UNNotificationRequest(identifier: prefijo + id, content: contenido, trigger: cuando)
        try? await centro.add(peticion)
    }
}
