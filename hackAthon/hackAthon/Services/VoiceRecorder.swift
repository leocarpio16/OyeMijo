//
//  VoiceRecorder.swift
//  hackAthon
//
//  Convierte una frase de Mijo en un archivo de audio (Library/Sounds) para
//  que sea el SONIDO de la notificación: el teléfono suena con la voz de
//  Mijo diciendo "Doña Mari, ¿ya cenó?" aunque la app esté cerrada.
//

import AVFoundation
import UserNotifications

enum VoiceRecorder {

    /// Sonido con la voz de Mijo; si no se puede grabar, el sonido normal.
    static func sonido(para texto: String) async -> UNNotificationSound {
        guard let carpeta = carpetaDeSonidos() else { return .default }
        let nombre = "mijo-\(huella(texto)).caf"
        let archivo = carpeta.appending(path: nombre)
        if !FileManager.default.fileExists(atPath: archivo.path()) {
            let grabado = await grabar(VoiceService.frase(texto), en: archivo, con: AVSpeechSynthesizer())
            guard grabado else { return .default }
        }
        return UNNotificationSound(named: UNNotificationSoundName(nombre))
    }

    /// iOS busca los sonidos de las notificaciones en Library/Sounds.
    private static func carpetaDeSonidos() -> URL? {
        let carpeta = URL.libraryDirectory.appending(path: "Sounds")
        try? FileManager.default.createDirectory(at: carpeta, withIntermediateDirectories: true)
        return carpeta
    }

    /// Número que identifica la frase: la misma frase usa el mismo archivo.
    private static func huella(_ texto: String) -> String {
        var hash: UInt64 = 5381
        for byte in texto.utf8 { hash = (hash &* 33) &+ UInt64(byte) }
        return String(hash, radix: 36)
    }

    /// El sintetizador "habla" hacia un archivo en lugar de la bocina.
    /// Va fuera del hilo principal: el sistema entrega el audio en pedazos desde otro hilo.
    nonisolated private static func grabar(_ frase: AVSpeechUtterance, en url: URL,
                                           con sintetizador: AVSpeechSynthesizer) async -> Bool {
        await withCheckedContinuation { continuacion in
            var archivo: AVAudioFile?
            var terminado = false
            func terminar(_ ok: Bool) {
                guard !terminado else { return }
                terminado = true
                archivo = nil // cierra el archivo antes de usarlo
                if !ok { try? FileManager.default.removeItem(at: url) }
                continuacion.resume(returning: ok)
            }
            sintetizador.write(frase) { buffer in
                // El último pedazo llega vacío: ahí termina.
                guard let pcm = buffer as? AVAudioPCMBuffer, pcm.frameLength > 0 else {
                    terminar(archivo != nil)
                    return
                }
                do {
                    if archivo == nil {
                        // PCM de 16 bits: uno de los formatos que acepta una notificación.
                        let ajustes: [String: Any] = [
                            AVFormatIDKey: kAudioFormatLinearPCM,
                            AVSampleRateKey: pcm.format.sampleRate,
                            AVNumberOfChannelsKey: pcm.format.channelCount,
                            AVLinearPCMBitDepthKey: 16,
                            AVLinearPCMIsFloatKey: false,
                            AVLinearPCMIsBigEndianKey: false,
                        ]
                        archivo = try AVAudioFile(forWriting: url, settings: ajustes,
                                                  commonFormat: pcm.format.commonFormat,
                                                  interleaved: pcm.format.isInterleaved)
                    }
                    try archivo?.write(from: pcm)
                } catch {
                    terminar(false)
                }
            }
        }
    }
}
