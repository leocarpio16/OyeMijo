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
    @Environment(\.dismiss) private var dismiss

    init(context: ModelContext, nombre: String) {
        _modelo = State(initialValue: ConversationModel(context: context, nombre: nombre))
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
            case .respondiendo(let respuesta):
                AnswerView(frase: modelo.frase,
                           respuesta: respuesta,
                           onBack: cerrar,
                           onRepeat: modelo.repetir,
                           onAction: ejecutar,
                           onTalk: { Task { await modelo.escuchar() } })
            }
        }
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
