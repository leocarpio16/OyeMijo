//
//  FamilyModel.swift
//  hackAthon
//
//  Modo familia: Mijo en el teléfono del nieto o del hijo. Escucha el mismo
//  tema de ntfy al que avisa el Mijo de la abuela y muestra cada aviso.
//  Se conecta a https://ntfy.sh/<tema>/json, que va mandando un renglón de
//  JSON por aviso mientras la app está abierta (en Python sería leer
//  `requests.get(url, stream=True).iter_lines()`).
//  Límite: con la app cerrada iOS la duerme; para eso sigue la app ntfy.
//

import Foundation
import Observation
import UIKit
import UserNotifications

/// Un aviso que mandó el Mijo de la abuela.
nonisolated struct AvisoFamiliar: Identifiable, Equatable, Sendable {
    let id: String
    let fecha: Date
    let titulo: String
    let mensaje: String
    /// 5 = urgente (caída con dolor, no se puede levantar), 4 = alta, 3 = normal.
    let prioridad: Int
    /// Botón "Ver en el mapa" del aviso, si traía ubicación.
    let mapa: URL?

    var urgente: Bool { prioridad >= 5 }
    /// "Ya se levantó" y "ya llegué": avisos de tranquilidad.
    var tranquilo: Bool { prioridad <= 3 }
}

@Observable
final class FamilyModel {
    let tema: String
    /// Del más nuevo al más viejo.
    private(set) var avisos: [AvisoFamiliar] = []
    private(set) var conectado = false

    /// Solo se avisa con sonido lo que llegue después de abrir la pantalla.
    @ObservationIgnored private let abierta = Date.now

    init(tema: String) {
        self.tema = tema
    }

    /// Escucha mientras la pantalla esté abierta; si se cae el internet, reintenta.
    func escuchar() async {
        _ = try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])
        while !Task.isCancelled {
            await conectar()
            conectado = false
            try? await Task.sleep(for: .seconds(3))
        }
    }

    private func conectar() async {
        guard let url = URL(string: "https://ntfy.sh/\(tema)/json?since=12h") else { return }
        do {
            let (renglones, _) = try await URLSession.shared.bytes(from: url)
            conectado = true
            for try await renglon in renglones.lines {
                guard let aviso = Self.leer(renglon), !avisos.contains(where: { $0.id == aviso.id }) else { continue }
                avisos.insert(aviso, at: 0)
                avisos.sort { $0.fecha > $1.fecha }
                if aviso.fecha >= abierta.addingTimeInterval(-5) { await sonar(aviso) }
            }
        } catch {
            return
        }
    }

    /// Un renglón de ntfy → aviso. nil si no es un mensaje (ntfy también manda "open" y "keepalive").
    private static func leer(_ renglon: String) -> AvisoFamiliar? {
        guard let datos = renglon.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: datos) as? [String: Any],
              json["event"] as? String == "message",
              let id = json["id"] as? String,
              let segundos = json["time"] as? Double else { return nil }
        let acciones = json["actions"] as? [[String: Any]] ?? []
        let mapa = acciones.first { $0["action"] as? String == "view" }?["url"] as? String
        return AvisoFamiliar(id: id, fecha: Date(timeIntervalSince1970: segundos),
                             titulo: json["title"] as? String ?? "Aviso de Mijo",
                             mensaje: json["message"] as? String ?? "",
                             prioridad: json["priority"] as? Int ?? 3,
                             mapa: mapa.flatMap(URL.init(string:)))
    }

    /// Aviso nuevo: notificación con sonido (se ve aunque la app esté abierta) y vibración.
    private func sonar(_ aviso: AvisoFamiliar) async {
        if aviso.urgente { Haptics.warning() } else { Haptics.success() }
        let contenido = UNMutableNotificationContent()
        contenido.title = aviso.titulo
        contenido.body = aviso.mensaje
        contenido.sound = .default
        try? await UNUserNotificationCenter.current()
            .add(UNNotificationRequest(identifier: aviso.id, content: contenido, trigger: nil))
    }

    func abrirMapa(_ aviso: AvisoFamiliar) {
        guard let mapa = aviso.mapa else { return }
        UIApplication.shared.open(mapa)
    }

    /// Acepta el tema solo ("mijo-sobas-4821") o el enlace completo del código QR.
    static func limpiar(_ texto: String) -> String {
        let texto = texto.trimmingCharacters(in: .whitespacesAndNewlines)
        let sinEnlace = texto.components(separatedBy: "ntfy.sh/").last ?? texto
        return sinEnlace.split(separator: "/").first.map(String.init) ?? ""
    }
}
