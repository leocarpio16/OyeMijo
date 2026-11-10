//
//  ContactPicker.swift
//  hackAthon
//
//  Abre la lista de Contactos del iPhone para elegir a la persona de
//  confianza. No pide permiso: el iPhone solo nos da el contacto elegido.
//

import ContactsUI
import SwiftUI

struct ContactPicker: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    let onPick: (PersonaDeConfianza) -> Void

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    // La lista de Contactos se abre encima de una vista vacía: presentarla
    // directo como hoja de SwiftUI la deja en blanco.
    func makeUIViewController(context: Context) -> UIViewController { UIViewController() }

    func updateUIViewController(_ controller: UIViewController, context: Context) {
        context.coordinator.parent = self
        guard isPresented, controller.presentedViewController == nil else { return }
        let picker = CNContactPickerViewController()
        picker.delegate = context.coordinator
        picker.displayedPropertyKeys = [CNContactPhoneNumbersKey]
        picker.predicateForEnablingContact = NSPredicate(format: "phoneNumbers.@count > 0")
        DispatchQueue.main.async { controller.present(picker, animated: true) }
    }

    final class Coordinator: NSObject, CNContactPickerDelegate {
        var parent: ContactPicker

        init(_ parent: ContactPicker) {
            self.parent = parent
        }

        func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
            let nombre = [contact.nickname, contact.givenName, contact.familyName].first { !$0.isEmpty } ?? ""
            let telefono = ContactsService.celular(de: contact) ?? ""
            parent.onPick(PersonaDeConfianza(nombre: nombre, telefono: telefono))
            parent.isPresented = false
        }

        func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
            parent.isPresented = false
        }
    }
}
