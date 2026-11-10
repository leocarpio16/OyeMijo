//
//  ConversationView.swift
//  hackAthon
//
//  La plática con Mijo: se abre desde el botón de Inicio y va cambiando
//  entre "Mijo escuchando" y "Mijo le contesta".
//

import SwiftUI
import SwiftData

struct ConversationView: View {
    @State private var modelo: ConversationModel
    private let context: ModelContext
    @Environment(\.dismiss) private var dismiss

    init(context: ModelContext, nombre: String) {
        _modelo = State(initialValue: ConversationModel(context: context, nombre: nombre))
        self.context = context
    }

    var body: some View {
        Group {
            switch modelo.fase {
            case .escuchando, .pensando:
                ListeningView(nombre: modelo.nombre,
                              texto: pensando ? modelo.frase : modelo.voz.textoEscuchado,
                              nivel: modelo.voz.nivel,
                              pensando: pensando,
                              onBack: cerrar,
                              onDone: { Task { await modelo.terminar() } })
                    .transition(.opacity)
            case .respondiendo(let respuesta):
                AnswerView(frase: modelo.frase,
                           respuesta: respuesta,
                           onBack: cerrar,
                           onRepeat: modelo.repetir,
                           onAction: ejecutar,
                           onTalk: { Task { await modelo.escuchar() } })
                    .transition(.opacity)
            case .emergencia(let motivo):
                // Protocolo fijo, sin IA: avisa a la familia y marca de una vez.
                HelpView(context: context, nombre: modelo.nombre, motivo: motivo, frase: modelo.frase)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: faseID)
        .task { await modelo.escuchar() }
        // Si ya dijo algo y se queda callada 2 segundos, se toma como "Ya terminé".
        .task(id: modelo.voz.textoEscuchado) {
            guard modelo.voz.escuchando, !modelo.voz.textoEscuchado.isEmpty else { return }
            try? await Task.sleep(for: .seconds(2))
            guard !Task.isCancelled else { return }
            await modelo.terminar()
        }
        .onDisappear { modelo.cerrar() }
    }

    /// Número de la fase, para animar el cambio entre pantallas.
    private var faseID: Int {
        switch modelo.fase {
        case .escuchando, .pensando: 0
        case .respondiendo: 1
        case .emergencia: 2
        }
    }

    private var pensando: Bool {
        if case .pensando = modelo.fase { true } else { false }
    }

    private func cerrar() {
        modelo.cerrar()
        dismiss()
    }

    private func ejecutar(_ accion: AccionDeMijo) {
        switch accion {
        case .llamar(let familiar):
            modelo.llamar(familiar)
        case .marcarTomada(let medicina):
            modelo.marcarTomada(medicina)
        }
    }
}

#Preview {
    let container = SampleData.previewContainer
    ConversationView(context: container.mainContext, nombre: "Doña Mari")
        .modelContainer(container)
}
