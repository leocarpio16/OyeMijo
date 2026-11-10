//
//  ContactsService.swift
//  hackAthon
//
//  Busca en los contactos del teléfono a la persona que nombró
//  ("dile a Pedro que ya comí" → Pedro Ramírez, su celular).
//  Se usa cuando la persona no es uno de sus familiares guardados en Mijo.
//  La primera vez iOS pide permiso; si no lo da, regresa nil.
//

import Contacts
import Foundation

nonisolated enum ContactsService {

    /// El contacto que mejor coincide con lo que dijo, con su celular; nil si no hay o no hay permiso.
    static func buscar(_ dicho: String) async -> (nombre: String, telefono: String)? {
        let tienda = CNContactStore()
        guard (try? await tienda.requestAccess(for: .contacts)) == true else { return nil }
        let palabras = Set(EmergencyRouter.normalizar(dicho).split(separator: " ").map(String.init))
            .subtracting(relleno)
        guard !palabras.isEmpty else { return nil }
        return await Task.detached { mejor(en: tienda, para: palabras) }.value
    }

    /// Palabras de la frase que no son parte de un nombre.
    private static let relleno: Set = ["un", "una", "whatsapp", "mensaje", "mensajito", "a", "al", "mi", "la",
                                       "el", "de", "que", "le", "por", "favor", "llamada", "llama", "marca"]

    /// Gana el contacto con más palabras de su nombre dichas ("Pedro Ramírez" le gana a "Pedro").
    private static func mejor(en tienda: CNContactStore, para palabras: Set<String>) -> (nombre: String, telefono: String)? {
        let claves = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactNicknameKey,
                      CNContactPhoneNumbersKey] as [CNKeyDescriptor]
        var mejor: (puntos: Int, nombre: String, telefono: String)?
        try? tienda.enumerateContacts(with: CNContactFetchRequest(keysToFetch: claves)) { contacto, _ in
            guard let telefono = celular(de: contacto) else { return }
            let nombre = [contacto.givenName, contacto.familyName, contacto.nickname].joined(separator: " ")
            let suyas = EmergencyRouter.normalizar(nombre).split(separator: " ").map(String.init)
            let puntos = suyas.filter { $0.count >= 3 && palabras.contains($0) }.count
            guard puntos > 0, puntos > (mejor?.puntos ?? 0) else { return }
            let comoDecirle = [contacto.nickname, contacto.givenName, contacto.familyName].first { !$0.isEmpty } ?? nombre
            mejor = (puntos, comoDecirle, telefono)
        }
        return mejor.map { ($0.nombre, $0.telefono) }
    }

    /// El celular primero: WhatsApp necesita el móvil, no el de casa.
    static func celular(de contacto: CNContact) -> String? {
        let movil = contacto.phoneNumbers.first {
            [CNLabelPhoneNumberMobile, CNLabelPhoneNumberiPhone].contains($0.label ?? "")
        }
        return (movil ?? contacto.phoneNumbers.first)?.value.stringValue
    }
}
