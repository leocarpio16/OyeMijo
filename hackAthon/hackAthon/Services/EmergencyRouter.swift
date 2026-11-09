//
//  EmergencyRouter.swift
//  hackAthon
//
//  Revisa lo que dijo la persona ANTES de mandarlo a la IA. Si suena a
//  emergencia ("me caí", "me siento mal", "ayuda"), la app se va directo al
//  protocolo fijo. Motivo: los filtros de Foundation Models bloquean temas de
//  lesiones y salud, y una emergencia tiene que responder siempre igual.
//

import Foundation

nonisolated enum Emergencia: Equatable {
    case caida
    case malestar
    case ayuda
}

nonisolated enum EmergencyRouter {

    /// nil si la frase no es una emergencia.
    static func detectar(_ frase: String) -> Emergencia? {
        let texto = normalizar(frase)
        if contiene(texto, caida) { return .caida }
        if contiene(texto, malestar) { return .malestar }
        // "ayuda" sola sí es emergencia; "ayúdame a llamar a Leo" no.
        if soloAyuda.contains(texto) || contiene(texto, ayuda) { return .ayuda }
        return nil
    }

    // Las frases van sin acentos y en minúsculas, igual que el texto normalizado.
    private static let caida = [
        "me cai", "me acabo de caer", "me he caido", "me resbale", "me tropece",
        "estoy tirad", "estoy en el suelo", "estoy en el piso",
        "no me puedo levantar", "no puedo levantarme", "no me puedo parar", "no puedo pararme",
    ]
    private static let malestar = [
        "me siento mal", "me siento muy mal", "me duele el pecho", "dolor en el pecho",
        "no puedo respirar", "me falta el aire", "me estoy ahogando",
        "me voy a desmayar", "me desmaye", "estoy maread", "me mareo",
        "estoy sangrando", "me pegue en la cabeza", "me golpee",
    ]
    private static let ayuda = [
        "auxilio", "socorro", "emergencia", "ambulancia", "911",
        "necesito ayuda", "ayuda por favor", "ayudame por favor",
    ]
    private static let soloAyuda = ["ayuda", "ayudame", "mijo ayuda", "mijo ayudame", "oye mijo ayuda"]

    private static func contiene(_ texto: String, _ frases: [String]) -> Bool {
        frases.contains { texto.contains($0) }
    }

    /// "¡Me CAÍ!" → "me cai": sin acentos, sin mayúsculas y sin signos.
    static func normalizar(_ frase: String) -> String {
        frase.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "es_MX"))
            .lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.union(.whitespaces).inverted)
            .joined()
            .trimmingCharacters(in: .whitespaces)
    }
}
