//
//  Fuentes.swift
//  hackAthon
//
//  Registra la letra DM Sans (Google Fonts, licencia OFL, gratis) que va
//  dentro de la app en DesignSystem/Fonts/. Se hace con Core Text al abrir
//  la app, así no hace falta declararla en el Info.plist.
//  Si algo falla, iOS usa la letra del sistema y la app sigue funcionando.
//

import CoreText
import Foundation

enum Fuentes {
    /// Se llama una vez en `hackAthonApp.init()`.
    static func registrar() {
        let archivos = FileManager.default.enumerator(at: Bundle.main.bundleURL, includingPropertiesForKeys: nil)
        while let url = archivos?.nextObject() as? URL {
            guard url.pathExtension == "ttf" else { continue }
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }
}
