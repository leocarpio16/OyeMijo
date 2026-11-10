//
//  NtfyService.swift
//  hackAthon
//
//  Manda avisos a los teléfonos de la familia con ntfy.sh (gratis, sin
//  cuenta). La familia instala la app ntfy y se suscribe al tema de la
//  abuela; cada aviso les llega como notificación.
//

import Foundation

nonisolated enum NtfyService {

    enum Prioridad: Int {
        case normal = 3
        case alta = 4
        /// Suena aunque el teléfono esté en silencio (si la familia lo permite en ntfy).
        case urgente = 5
    }

    /// Manda el aviso. Regresa true si ntfy.sh lo recibió.
    @discardableResult
    static func avisar(tema: String, titulo: String, mensaje: String,
                       prioridad: Prioridad, etiquetas: [String] = [], mapa: URL? = nil) async -> Bool {
        // Se manda como JSON para que los acentos y la ñ lleguen bien.
        var cuerpo: [String: Any] = [
            "topic": tema,
            "title": titulo,
            "message": mensaje,
            "priority": prioridad.rawValue,
            "tags": etiquetas,
        ]
        if let mapa {
            // Botón "Ver en el mapa" dentro de la notificación de la familia.
            cuerpo["actions"] = [["action": "view", "label": "Ver en el mapa", "url": mapa.absoluteString]]
        }
        guard let url = URL(string: "https://ntfy.sh/"),
              let datos = try? JSONSerialization.data(withJSONObject: cuerpo) else { return false }
        var peticion = URLRequest(url: url, timeoutInterval: 10)
        peticion.httpMethod = "POST"
        peticion.setValue("application/json", forHTTPHeaderField: "Content-Type")
        peticion.httpBody = datos
        do {
            let (_, respuesta) = try await URLSession.shared.data(for: peticion)
            return (respuesta as? HTTPURLResponse)?.statusCode == 200
        } catch {
            return false
        }
    }
}
