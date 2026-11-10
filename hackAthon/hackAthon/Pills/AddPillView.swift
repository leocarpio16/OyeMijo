//
//  AddPillView.swift
//  hackAthon
//
//  "Agregar pastilla", desde "Sus pastillas de hoy". Dos maneras, en la
//  misma pantalla:
//  - Decirlo: toca el micrófono y dice "la de la presión a las 9 de la noche";
//    Mijo llena los campos (con las mismas reglas que ComandosDeVoz, sin IA).
//  - Escribirlo: los mismos campos a mano y la hora con la ruedita.
//  Nada se guarda hasta tocar Guardar, para que revise lo que entendió.
//

import SwiftUI
import SwiftData

struct AddPillView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var voz = VoiceService()
    @State private var paraQue = ""
    @State private var nombre = ""
    @State private var dosis = ""
    @State private var hora = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: .now) ?? .now
    /// Lo que entendió por voz, para que lo vea escrito.
    @State private var aviso: String?

    private var listo: Bool { !paraQue.trimmingCharacters(in: .whitespaces).isEmpty }

    var body: some View {
        VStack(spacing: Theme.Spacing.l) {
            HStack {
                RoundIconButton(systemImage: "arrow.left", label: "Regresar") { dismiss() }
                Spacer()
            }

            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.xl) {
                    Text("Agregar pastilla")
                        .display(Theme.Typography.titleSize)
                        .foregroundStyle(Theme.Palette.cafe)

                    decirlo

                    VStack(alignment: .leading, spacing: Theme.Spacing.l) {
                        Text("O escríbala")
                            .font(Theme.Typography.stepLabel)
                            .foregroundStyle(Theme.Palette.cafeSoft)
                        campo("¿Para qué es?", "la presión", $paraQue)
                        campo("Nombre (si lo sabe)", "Losartán", $nombre)
                        campo("Cuánto (si lo sabe)", "50 mg", $dosis)
                        VStack(alignment: .leading, spacing: Theme.Spacing.s) {
                            Text("¿A qué hora?")
                                .font(Theme.Typography.fieldLabel)
                                .foregroundStyle(Theme.Palette.cafeSoft)
                            DatePicker("Hora", selection: $hora, displayedComponents: .hourAndMinute)
                                .datePickerStyle(.wheel)
                                .labelsHidden()
                                .environment(\.locale, Locale(identifier: "es_MX"))
                                .frame(maxWidth: .infinity)
                                .background(Theme.Palette.surface, in: .rect(cornerRadius: Theme.Radius.input))
                        }
                    }
                }
                .padding(.bottom, Theme.Spacing.l)
            }
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)

            PrimaryButton(title: "Guardar", systemImage: "checkmark", action: guardar)
                .disabled(!listo)
                .opacity(listo ? 1 : 0.4)
        }
        .padding(.horizontal, Theme.Spacing.screen)
        .padding(.top, Theme.Spacing.xs)
        .padding(.bottom, Theme.Spacing.s)
        .background(Theme.Palette.cream.ignoresSafeArea())
        .onDisappear {
            voz.terminarDeEscuchar()
            voz.callar()
        }
    }

    // MARK: Decirlo

    /// Tarjeta ámbar con el micrófono: escucha, y al tocar otra vez llena los campos.
    private var decirlo: some View {
        HStack(spacing: Theme.Spacing.l) {
            RoundIconButton(systemImage: voz.escuchando ? "stop.fill" : "mic",
                            label: voz.escuchando ? "Ya terminé" : "Decirlo con su voz",
                            size: Theme.Size.actionButton, background: Theme.Palette.brandAmber,
                            iconColor: Theme.Palette.brandBrown,
                            shadow: Theme.Palette.amberGlow.opacity(0.4)) {
                Task { await alTocarMicrofono() }
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(voz.escuchando ? "Le escucho…" : "Dígamelo")
                    .font(Theme.Typography.cardName)
                    .foregroundStyle(Theme.Palette.cafe)
                Text(voz.escuchando ? (voz.textoEscuchado.isEmpty ? "Toque otra vez al terminar" : voz.textoEscuchado)
                                    : (aviso ?? "«La de la presión a las 9 de la noche»"))
                    .font(Theme.Typography.cardRow)
                    .foregroundStyle(Theme.Palette.cafeSoft)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(Theme.Spacing.l)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.Palette.answerGlow, in: .rect(cornerRadius: Theme.Radius.card))
    }

    private func alTocarMicrofono() async {
        if voz.escuchando {
            entender(voz.terminarDeEscuchar())
            return
        }
        aviso = nil
        guard await voz.pedirPermisos() else {
            aviso = "Falta el permiso del micrófono. Puede escribirla abajo."
            return
        }
        try? voz.empezarAEscuchar()
    }

    /// "La de la presión a las 9 de la noche" → para qué y hora en los campos.
    private func entender(_ dicho: String) {
        var frase = dicho.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !frase.isEmpty else {
            aviso = "No le escuché. Toque el micrófono y dígamelo otra vez."
            return
        }
        // Se arma como "recuérdame la pastilla de…" para usar las mismas reglas que la plática.
        for inicio in ["la de ", "el de ", "la del ", "para la ", "para el ", "para "]
        where frase.lowercased().hasPrefix(inicio) {
            frase = (inicio.hasSuffix("del ") ? "el " : inicio.hasPrefix("para ") ? String(inicio.dropFirst(5)) : "")
                + frase.dropFirst(inicio.count)
            break
        }
        let mencionaPastilla = ["pastilla", "medicina", "medicamento"].contains { frase.lowercased().contains($0) }
        let orden = ComandosDeVoz.entender((mencionaPastilla ? "recuérdame " : "recuérdame la pastilla de ") + frase)
        var texto: String
        switch orden {
        case .recordatorio(let para, let h, let m):
            if !para.isEmpty { paraQue = para }
            ponerHora(h, m)
            texto = "Entendí: \(para.isEmpty ? "su pastilla" : "la de \(para)") a las \(Horario(hora: h, minuto: m).texto). Revise y toque Guardar."
        case .recordatorioSinPeriodo(let para, let h, let m):
            if !para.isEmpty { paraQue = para }
            ponerHora(h, m)
            texto = "¿A las \(h) de la mañana o de la noche? Ajuste la hora abajo y toque Guardar."
        default:
            let para = frase.components(separatedBy: " a las ").first ?? frase
            if !para.isEmpty { paraQue = para }
            texto = "No entendí la hora. Póngala abajo con la ruedita y toque Guardar."
        }
        aviso = texto
        Haptics.tap()
        Task { await voz.hablar(texto) }
    }

    private func ponerHora(_ h: Int, _ m: Int) {
        hora = Calendar.current.date(bySettingHour: h, minute: m, second: 0, of: .now) ?? hora
    }

    // MARK: Escribirlo

    private func campo(_ etiqueta: String, _ ejemplo: String, _ texto: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.s) {
            Text(etiqueta)
                .font(Theme.Typography.fieldLabel)
                .foregroundStyle(Theme.Palette.cafeSoft)
            TextField(ejemplo, text: texto)
                .font(Theme.Typography.pill)
                .foregroundStyle(Theme.Palette.cafe)
                .padding(.horizontal, Theme.Spacing.l)
                .frame(minHeight: Theme.Size.infoPill)
                .background(Theme.Palette.surface, in: .rect(cornerRadius: Theme.Radius.input))
        }
    }

    private func guardar() {
        let partes = Calendar.current.dateComponents([.hour, .minute], from: hora)
        let acciones = MijoActions(context: context)
        _ = acciones.crearRecordatorio(paraQue: paraQue.trimmingCharacters(in: .whitespaces),
                                       hora: partes.hour ?? 9, minuto: partes.minute ?? 0,
                                       nombre: nombre.trimmingCharacters(in: .whitespaces),
                                       dosis: dosis.trimmingCharacters(in: .whitespaces))
        Haptics.success()
        let frase = acciones.frase ?? "Listo, ya la guardé."
        voz.terminarDeEscuchar()
        Task {
            await voz.hablar(frase)
        }
        dismiss()
    }
}

#Preview {
    AddPillView()
        .modelContainer(SampleData.previewContainer)
}
