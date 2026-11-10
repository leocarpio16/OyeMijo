//
//  QRCode.swift
//  hackAthon
//
//  Dibuja un código QR con CoreImage (viene en el iPhone, sin librerías).
//

import CoreImage.CIFilterBuiltins
import SwiftUI

enum QRCode {
    /// Imagen del QR para `texto`; nil si no se pudo crear.
    static func imagen(_ texto: String) -> Image? {
        let filtro = CIFilter.qrCodeGenerator()
        filtro.message = Data(texto.utf8)
        filtro.correctionLevel = "M"
        guard let salida = filtro.outputImage?.transformed(by: CGAffineTransform(scaleX: 12, y: 12)),
              let cgImage = CIContext().createCGImage(salida, from: salida.extent) else { return nil }
        return Image(decorative: cgImage, scale: 1).interpolation(.none)
    }
}
