//
//  HelpView.swift
//  hackAthon
//
//  Pantalla de emergencia con los colores del equipo y el acomodo de las
//  plantillas que eligió Leo: título arriba, una ilustración grande sobre
//  una mancha suave, barra de avance y controles redondos abajo.
//  - Pregunta: "¿Está bien?" (en una caída: "¿Le duele algo?") con 30 s.
//  - Caída sin dolor: los pasos para levantarse, uno a la vez (⏮ 🔊 ⏭).
//  - Aviso enviado: a quién se llamó, dónde está y la ficha médica.
//  Regla de marca: Mijo no aparece junto a una alerta de emergencia.
//

import SwiftUI
import SwiftData

struct HelpView: View {
    @State private var modelo: HelpModel
    @Environment(\.dismiss) private var dismiss

    /// - Parameter frase: lo que dijo con Mijo ("me caí"); nil si tocó el botón Ayuda.
    init(context: ModelContext, nombre: String, motivo: Emergencia, frase: String? = nil) {
        _modelo = State(initialValue: HelpModel(context: context, nombre: nombre, motivo: motivo, frase: frase))
    }

    var body: some View {
        VStack(spacing: Theme.Spacing.l) {
            barra
                .padding(.horizontal, margen)

            // El margen va dentro del scroll para que nada se corte en los bordes.
            ScrollView {
                VStack(spacing: Theme.Spacing.xl) {
                    if avisado {
                        avisoEnviado
                    } else {
                        ilustracion
                        if case .levantandose(let paso) = modelo.fase {
                            pasos(paso)
                        } else {
                            pregunta
                        }
                    }
                }
                .padding(.horizontal, margen)
                .padding(.bottom, Theme.Spacing.l)
            }
            .scrollBounceBehavior(.basedOnSize)
            .scrollIndicators(.hidden)

            controles
                .padding(.horizontal, margen)
        }
        .padding(.top, Theme.Spacing.xs)
        .padding(.bottom, Theme.Spacing.s)
        .background(Theme.Palette.cream.ignoresSafeArea())
        .animation(.easeInOut(duration: 0.3), value: modelo.fase)
        .task { await modelo.empezar() }
        .task { await modelo.contar() }
        .onChange(of: modelo.voz.textoEscuchado) { _, texto in modelo.revisar(texto) }
        .onChange(of: modelo.fase) { _, fase in
            if fase == .bien { dismiss() }
        }
        .onDisappear { modelo.cerrar() }
    }

    // MARK: Estado

    private let margen = Theme.Spacing.screen

    private var avisado: Bool {
        if case .avisado = modelo.fase { true } else { false }
    }

    private var levantandose: Bool {
        if case .levantandose = modelo.fase { true } else { false }
    }

    private var totalDePasos: Int { HelpModel.pasosParaLevantarse.count }

    // MARK: Barra de arriba

    /// Título centrado; al final, botón redondo para cerrar a la izquierda.
    private var barra: some View {
        ZStack {
            Text(tituloDeBarra)
                .font(Theme.Typography.rowTitle)
                .foregroundStyle(levantandose ? Theme.Palette.cafe : Theme.Palette.help)
                .padding(.horizontal, Theme.Size.roundButton + Theme.Spacing.s)
                .multilineTextAlignment(.center)
            if avisado {
                RoundIconButton(systemImage: "xmark", label: "Cerrar") { dismiss() }
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(minHeight: Theme.Size.roundButton)
    }

    private var tituloDeBarra: String {
        if avisado { return "Aviso enviado" }
        if levantandose { return "Paso a paso" }
        return modelo.etiqueta
    }

    // MARK: Ilustración

    /// Ilustración grande de línea sobre la mancha: rosa en la alerta, ámbar claro en los pasos.
    private var ilustracion: some View {
        ZStack {
            BlobShape()
                .fill(levantandose ? Theme.Palette.answerGlow : Theme.Palette.helpGlow)
            Image(systemName: simbolo)
                .font(.system(size: Theme.Size.illustration * escala, weight: .light))
                .foregroundStyle(Theme.Palette.cafe)
                .contentTransition(.symbolEffect(.replace))
        }
        .frame(height: Theme.Size.blob * escala)
        .accessibilityHidden(true)
    }

    /// En los pasos la ilustración es más chica para que el texto del paso quepa completo.
    private var escala: CGFloat { levantandose ? 0.62 : 1 }

    private var simbolo: String {
        switch modelo.fase {
        case .levantandose(let paso):
            let dibujos = ["wind", "figure.core.training", "figure.flexibility",
                           "chair", "figure.step.training", "figure.seated.side"]
            return paso < dibujos.count ? dibujos[paso] : "figure.stand"
        case .avisando:
            return "antenna.radiowaves.left.and.right"
        default:
            switch modelo.motivo {
            case .caida: return "figure.fall"
            case .malestar: return "cross.case"
            case .ayuda: return "hand.raised"
            }
        }
    }

    // MARK: Pregunta y cuenta regresiva

    private var pregunta: some View {
        VStack(spacing: Theme.Spacing.l) {
            Text(textoPregunta)
                .display(Theme.Typography.answerSize, weight: .semibold)
                .foregroundStyle(Theme.Palette.cafe)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            if modelo.fase == .preguntando {
                VStack(spacing: Theme.Spacing.s) {
                    HStack {
                        Text("Si no contesta, pido ayuda en")
                        Spacer(minLength: Theme.Spacing.s)
                        Text("\(modelo.segundos) s")
                            .font(Theme.Typography.status)
                            .foregroundStyle(Theme.Palette.cafe)
                            .contentTransition(.numericText(countsDown: true))
                    }
                    .font(Theme.Typography.cardRow)
                    .foregroundStyle(Theme.Palette.cafeSoft)

                    BarraQueSeVacia(valor: Double(modelo.segundos) / Double(HelpModel.segundosParaContestar))
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Si no contesta, pido ayuda en \(modelo.segundos) segundos")
            }
        }
    }

    private var textoPregunta: String {
        if modelo.fase == .avisando { return "Avisando a su familia…" }
        return modelo.preguntaDolor ? "\(modelo.nombre), ¿le duele algo?" : "\(modelo.nombre), ¿está bien?"
    }

    // MARK: Pasos para levantarse

    private func pasos(_ paso: Int) -> some View {
        let alFinal = paso >= totalDePasos
        return VStack(spacing: Theme.Spacing.l) {
            VStack(spacing: Theme.Spacing.s) {
                HStack {
                    Text(alFinal ? "Último paso" : "Paso \(paso + 1) de \(totalDePasos)")
                        .font(Theme.Typography.stepLabel)
                        .foregroundStyle(Theme.Palette.cafe)
                    Spacer(minLength: Theme.Spacing.s)
                    Text("Dígame «ya»")
                        .font(Theme.Typography.cardRow)
                        .foregroundStyle(Theme.Palette.cafeSoft)
                }
                BarraDePasos(total: totalDePasos, hechos: paso)
            }
            Text(alFinal ? "¿Ya se pudo levantar?" : HelpModel.pasosParaLevantarse[paso])
                .display(Theme.Typography.answerSize, weight: .semibold)
                .foregroundStyle(Theme.Palette.cafe)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .contentTransition(.opacity)
        }
    }

    // MARK: Aviso enviado

    private var avisoEnviado: some View {
        VStack(spacing: Theme.Spacing.l) {
            // Tarjeta plana con ilustración al centro, como las tarjetas de la plantilla.
            VStack(spacing: Theme.Spacing.m) {
                Image(systemName: modelo.familiar == nil ? "house" : "phone.badge.waveform")
                    .font(.system(size: Theme.Size.illustration * 0.7, weight: .light))
                    .foregroundStyle(Theme.Palette.cafe)
                    .accessibilityHidden(true)
                Text(enviado ? "Ya le avisé a su familia" : "No pude mandar el aviso")
                    .display(Theme.Typography.answerSize, weight: .semibold)
                    .foregroundStyle(Theme.Palette.cafe)
                Text(modelo.familiar.map { "Le estoy marcando a \($0.nombre)" } ?? "Si es urgente, llame al 911")
                    .font(Theme.Typography.support)
                    .foregroundStyle(Theme.Palette.cafeSoft)
                if let direccion = modelo.ubicacion?.direccionCorta {
                    Label(direccion, systemImage: "location.fill")
                        .font(Theme.Typography.cardRowBold)
                        .foregroundStyle(Theme.Palette.cafe)
                }
            }
            .multilineTextAlignment(.center)
            .padding(Theme.Spacing.section)
            .frame(maxWidth: .infinity)
            .background(Theme.Palette.helpGlow, in: .rect(cornerRadius: Theme.Radius.card))

            if let ficha = modelo.ficha { FichaCard(ficha: ficha) }
        }
    }

    private var enviado: Bool {
        if case .avisado(let enviado) = modelo.fase { enviado } else { false }
    }

    // MARK: Controles de abajo

    @ViewBuilder private var controles: some View {
        VStack(spacing: Theme.Spacing.s + 2) {
            if avisado {
                if let familiar = modelo.familiar {
                    PrimaryButton(title: "Llamar a \(familiar.nombre)", systemImage: "phone",
                                  color: Theme.Palette.help) { modelo.llamar(familiar) }
                }
            } else if levantandose {
                reproductor
                PrimaryButton(title: "Ya me levanté", systemImage: "checkmark") {
                    Task { await modelo.yaMeLevante() }
                }
                PrimaryButton(title: "No puedo levantarme", systemImage: "exclamationmark.triangle",
                              color: Theme.Palette.help) {
                    Task { await modelo.noPuedoLevantarme() }
                }
            } else if modelo.preguntaDolor {
                PrimaryButton(title: "No me duele", systemImage: "checkmark") {
                    Task { await modelo.noMeDuele() }
                }
                PrimaryButton(title: "Sí, me duele", systemImage: "exclamationmark.triangle",
                              color: Theme.Palette.help) {
                    Task { await modelo.pedirAyuda() }
                }
            } else {
                PrimaryButton(title: "Sí, estoy bien", systemImage: "checkmark") {
                    Task { await modelo.estoyBien() }
                }
                PrimaryButton(title: "Necesito ayuda", systemImage: "exclamationmark.triangle",
                              color: Theme.Palette.help) {
                    Task { await modelo.pedirAyuda() }
                }
            }
            // En los pasos, "No puedo levantarme" ya lleva a la ayuda.
            if !levantandose {
                Button("Llamar al 911", action: modelo.llamarAl911)
                    .font(Theme.Typography.textButton)
                    .foregroundStyle(Theme.Palette.help)
                    .frame(maxWidth: .infinity, minHeight: Theme.Size.textButton)
            }
        }
        .disabled(modelo.fase == .avisando)
    }

    /// ⏮ paso anterior · 🔊 repetir (grande) · ⏭ siguiente, como un reproductor.
    private var reproductor: some View {
        HStack(spacing: Theme.Spacing.xl) {
            RoundIconButton(systemImage: "backward.fill", label: "Paso anterior", action: modelo.pasoAnterior)
            RoundIconButton(systemImage: "speaker.wave.2.fill", label: "Repetir el paso",
                            size: Theme.Size.actionButton + Theme.Spacing.m, background: Theme.Palette.brandBrown,
                            iconColor: Theme.Palette.surface, action: modelo.repetirPaso)
            RoundIconButton(systemImage: "forward.fill", label: "Siguiente paso", action: modelo.siguientePaso)
        }
        .padding(.bottom, Theme.Spacing.xs)
    }
}

// MARK: - Piezas

/// Línea roja que se va vaciando con la cuenta regresiva.
private struct BarraQueSeVacia: View {
    let valor: Double

    var body: some View {
        GeometryReader { espacio in
            ZStack(alignment: .leading) {
                Capsule().fill(Theme.Palette.helpTrack)
                Capsule().fill(Theme.Palette.help)
                    .frame(width: espacio.size.width * max(0, min(valor, 1)))
                    .animation(.linear(duration: 1), value: valor)
            }
        }
        .frame(height: Theme.Size.progressBar)
    }
}

/// Un segmento por paso: café los que ya pasaron y el actual, tenue los que faltan.
private struct BarraDePasos: View {
    let total: Int
    let hechos: Int

    var body: some View {
        HStack(spacing: Theme.Spacing.xs) {
            ForEach(0..<total, id: \.self) { paso in
                Capsule()
                    .fill(paso <= hechos ? Theme.Palette.cafe : Theme.Palette.stepPending)
                    .frame(height: Theme.Size.progressBar)
            }
        }
        .accessibilityHidden(true)
    }
}

/// Ficha médica para quien llegue a ayudar (familia, paramédicos).
private struct FichaCard: View {
    let ficha: FichaMedica

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.m) {
            VStack(alignment: .leading, spacing: 0) {
                Text("Para quien venga a ayudar")
                    .font(Theme.Typography.cardRowBold)
                    .foregroundStyle(Theme.Palette.cafeSoft)
                Text(ficha.nombreCompleto)
                    .font(Theme.Typography.cardName)
                    .foregroundStyle(Theme.Palette.cafe)
                Text("\(ficha.edad) años · Sangre \(ficha.tipoDeSangre)")
                    .font(Theme.Typography.cardRow)
                    .foregroundStyle(Theme.Palette.cafe)
            }
            renglon("Alergias", ficha.alergias)
            renglon("Padecimientos", ficha.padecimientos)
            if !ficha.notas.isEmpty { renglon("Notas", ficha.notas) }
        }
        .padding(Theme.Spacing.section)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.Palette.surface, in: .rect(cornerRadius: Theme.Radius.card))
    }

    private func renglon(_ etiqueta: String, _ valor: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(etiqueta)
                .font(Theme.Typography.cardRowBold)
                .foregroundStyle(Theme.Palette.cafeSoft)
            Text(valor)
                .font(Theme.Typography.cardRow)
                .foregroundStyle(Theme.Palette.cafe)
        }
    }
}

#Preview {
    let container = SampleData.previewContainer
    HelpView(context: container.mainContext, nombre: "Doña Mari", motivo: .caida)
        .modelContainer(container)
}
