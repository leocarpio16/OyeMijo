//
//  HelpView.swift
//  hackAthon
//
//  Pantalla de emergencia, con los colores del equipo y el acomodo del diseño
//  que eligió Leo: avance y "Llamar al 911" arriba, una ilustración grande,
//  título y explicación alineados a la izquierda, y los botones abajo.
//  - Pregunta: "¿Está bien?" (en una caída: "¿Le duele algo?") con 30 s.
//  - Caída sin dolor: los pasos para levantarse, uno a la vez (← 🔊 Siguiente).
//  - Se levantó: "¡Muy bien!" y la familia recibe el aviso de que está bien.
//  - Aviso enviado: a quién se llamó, dónde está y la ficha médica.
//  Regla de marca: Mijo no aparece junto a una alerta de emergencia.
//

import SwiftUI
import SwiftData

struct HelpView: View {
    @State private var modelo: HelpModel
    @Environment(\.dismiss) private var dismiss
    @State private var confirmarCancelar = false

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
                VStack(alignment: .leading, spacing: Theme.Spacing.xl) {
                    SceneIllustration(symbol: simbolo, tint: enCalma ? Theme.Palette.answerGlow : Theme.Palette.helpGlow)
                    switch modelo.fase {
                    case .levantandose(let paso): pasos(paso)
                    case .levantado: felicitacion
                    case .avisado: avisoEnviado
                    default: pregunta
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
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

    /// Pasos y felicitación van en ámbar tranquilo; la alerta, en rosa.
    private var enCalma: Bool { levantandose || modelo.fase == .levantado }

    private var totalDePasos: Int { HelpModel.pasosParaLevantarse.count }

    // MARK: Barra de arriba

    /// A la izquierda, en qué va (alerta o avance de los pasos); a la derecha, el 911 siempre a la mano.
    private var barra: some View {
        HStack(spacing: Theme.Spacing.s) {
            if case .levantandose(let paso) = modelo.fase {
                Avance(actual: paso, total: totalDePasos)
            } else if modelo.fase == .levantado {
                Label("Ya se levantó", systemImage: "checkmark.circle.fill")
                    .font(Theme.Typography.alertPill)
                    .foregroundStyle(Theme.Palette.taken)
            } else {
                Label(avisado ? "Aviso enviado" : modelo.etiqueta, systemImage: "exclamationmark.triangle.fill")
                    .font(Theme.Typography.alertPill)
                    .foregroundStyle(Theme.Palette.help)
            }
            Spacer(minLength: Theme.Spacing.s)
            if modelo.fase != .levantado {
                WhitePill(title: "911", systemImage: "phone.fill",
                          color: Theme.Palette.help, iconColor: Theme.Palette.help,
                          font: Theme.Typography.helpPill, height: Theme.Size.helpPill,
                          fullWidth: false, shadowOpacity: 0.14, action: modelo.llamarAl911)
                    .accessibilityLabel("Llamar al 911")
            }
        }
        .frame(minHeight: Theme.Size.helpPill)
    }

    // MARK: Ilustración

    private var simbolo: String {
        switch modelo.fase {
        case .levantandose(let paso):
            let dibujos = ["wind", "figure.core.training", "figure.flexibility",
                           "chair", "figure.step.training", "figure.seated.side"]
            return paso < dibujos.count ? dibujos[paso] : "figure.stand"
        case .levantado:
            return "figure.seated.side"
        case .avisando:
            return "antenna.radiowaves.left.and.right"
        case .avisado:
            return modelo.familiar == nil ? "house" : "phone.badge.waveform"
        default:
            switch modelo.motivo {
            case .caida: return "figure.fall"
            case .malestar: return "cross.case"
            case .ayuda: return "hand.raised"
            }
        }
    }

    // MARK: Textos

    /// Título grande y explicación gris, alineados a la izquierda.
    private func textos(_ titulo: String, _ apoyo: String) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.m) {
            Text(titulo)
                .display(Theme.Typography.answerSize)
                .foregroundStyle(Theme.Palette.cafe)
                .contentTransition(.opacity)
            Text(apoyo)
                .font(Theme.Typography.support)
                .foregroundStyle(Theme.Palette.cafeSoft)
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    /// "✓ Su familia ya sabe": para que se sienta acompañada mientras se levanta.
    private func familiaEnterada(_ texto: String) -> some View {
        Label(texto, systemImage: "checkmark.circle.fill")
            .font(Theme.Typography.cardRowBold)
            .foregroundStyle(Theme.Palette.taken)
            .padding(.horizontal, Theme.Spacing.l)
            .frame(minHeight: Theme.Size.chip)
            .background(Theme.Palette.surface, in: .capsule)
    }

    // MARK: Pregunta y cuenta regresiva

    private var pregunta: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xl) {
            if modelo.fase == .avisando {
                textos("Avisando a su familia…", "Aquí estoy con usted. No cuelgue.")
            } else {
                textos(modelo.preguntaDolor ? "\(modelo.nombre), ¿le duele algo?" : "\(modelo.nombre), ¿está bien?",
                       "Toque un botón o dígamelo con su voz.")
            }

            if modelo.fase == .preguntando {
                VStack(spacing: Theme.Spacing.s) {
                    HStack(alignment: .firstTextBaseline) {
                        Text("Si no contesta, pido ayuda en")
                            .font(Theme.Typography.cardRow)
                            .foregroundStyle(Theme.Palette.cafeSoft)
                        Spacer(minLength: Theme.Spacing.s)
                        Text("\(modelo.segundos) s")
                            .font(Theme.Typography.countdown)
                            .foregroundStyle(Theme.Palette.help)
                            .contentTransition(.numericText(countsDown: true))
                    }
                    BarraQueSeVacia(valor: Double(modelo.segundos) / Double(HelpModel.segundosParaContestar))
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Si no contesta, pido ayuda en \(modelo.segundos) segundos")
            }
        }
    }

    // MARK: Pasos para levantarse

    private func pasos(_ paso: Int) -> some View {
        let alFinal = paso >= totalDePasos
        return VStack(alignment: .leading, spacing: Theme.Spacing.l) {
            Text(alFinal ? "Último paso" : "Paso \(paso + 1) de \(totalDePasos)")
                .font(Theme.Typography.stepLabel)
                .foregroundStyle(Theme.Palette.cafeSoft)
            textos(alFinal ? "¿Ya se pudo levantar?" : HelpModel.pasosParaLevantarse[paso],
                   alFinal ? "Si no puede, yo pido ayuda por usted." : HelpModel.detalleDePasos[paso])
            if modelo.familiaAvisada {
                familiaEnterada("Su familia ya sabe")
            }
        }
    }

    // MARK: Ya se levantó

    private var felicitacion: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.l) {
            textos("¡Muy bien, \(modelo.nombre)!", "Siéntese y descanse un rato antes de caminar. Si se marea o le duele algo, dígame.")
            familiaEnterada("Su familia ya sabe que está bien")
        }
    }

    // MARK: Aviso enviado

    private var avisoEnviado: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.l) {
            textos(enviado ? "Ya le avisé a su familia" : "No pude mandar el aviso",
                   modelo.familiar.map { "Le estoy marcando a \($0.nombre). No se mueva, ya viene la ayuda." }
                       ?? "Si es urgente, toque 911 arriba.")
            if let direccion = modelo.ubicacion?.direccionCorta {
                Label(direccion, systemImage: "location.fill")
                    .font(Theme.Typography.cardRowBold)
                    .foregroundStyle(Theme.Palette.cafe)
                    .padding(.horizontal, Theme.Spacing.l)
                    .frame(minHeight: Theme.Size.chip)
                    .background(Theme.Palette.surface, in: .capsule)
            }
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
                botonCancelar
            } else if case .levantandose(let paso) = modelo.fase {
                navegacion(alFinal: paso >= totalDePasos)
                PrimaryButton(title: "No puedo levantarme", systemImage: "exclamationmark.triangle",
                              color: Theme.Palette.help) {
                    Task { await modelo.noPuedoLevantarme() }
                }
                botonCancelar
            } else if modelo.fase == .levantado {
                PrimaryButton(title: "Terminar", systemImage: "checkmark") { dismiss() }
            } else if modelo.preguntaDolor {
                PrimaryButton(title: "No me duele", systemImage: "checkmark") {
                    Task { await modelo.noMeDuele() }
                }
                PrimaryButton(title: "Sí, me duele", systemImage: "exclamationmark.triangle",
                              color: Theme.Palette.help) {
                    Task { await modelo.pedirAyuda() }
                }
                botonCancelar
            } else {
                PrimaryButton(title: "Sí, estoy bien", systemImage: "checkmark") {
                    Task { await modelo.estoyBien() }
                }
                PrimaryButton(title: "Necesito ayuda", systemImage: "exclamationmark.triangle",
                              color: Theme.Palette.help) {
                    Task { await modelo.pedirAyuda() }
                }
                botonCancelar
            }
        }
        .disabled(modelo.fase == .avisando)
        .confirmationDialog(modelo.familiaYaSabe ? "¿Fue un error? Le aviso a su familia que está bien."
                                                 : "¿Cancelar la alerta?",
                            isPresented: $confirmarCancelar, titleVisibility: .visible) {
            Button("Sí, fue un error", role: .destructive, action: modelo.cancelar)
            if avisado { Button("Solo cerrar") { dismiss() } }
            Button("No, seguir", role: .cancel) {}
        }
    }

    /// "Cancelar, fue un error": por si tocó Ayuda sin querer o ya está bien.
    private var botonCancelar: some View {
        Button {
            Haptics.tap()
            confirmarCancelar = true
        } label: {
            Label("Cancelar, fue un error", systemImage: "xmark")
                .font(Theme.Typography.textButton)
                .foregroundStyle(Theme.Palette.cafe)
                .frame(maxWidth: .infinity, minHeight: Theme.Size.textButton)
        }
        .buttonStyle(.plain)
    }

    /// ← paso anterior · 🔊 repetir · botón largo para seguir (al final: "Ya me levanté").
    private func navegacion(alFinal: Bool) -> some View {
        HStack(spacing: Theme.Spacing.m) {
            RoundIconButton(systemImage: "arrow.left", label: "Paso anterior", size: Theme.Size.actionButton,
                            background: Theme.Palette.cafe, iconColor: Theme.Palette.surface,
                            action: modelo.pasoAnterior)
            RoundIconButton(systemImage: "speaker.wave.2.fill", label: "Repetir el paso",
                            size: Theme.Size.actionButton, action: modelo.repetirPaso)
            if alFinal {
                PrimaryButton(title: "Ya me levanté", systemImage: "checkmark") {
                    Task { await modelo.yaMeLevante() }
                }
            } else {
                PrimaryButton(title: "Siguiente", systemImage: "arrow.right", action: modelo.siguientePaso)
            }
        }
    }
}

/// Avance de los pasos: una rayita larga ámbar en el actual y puntos en los demás.
private struct Avance: View {
    let actual: Int
    let total: Int

    var body: some View {
        HStack(spacing: 5) {
            ForEach(0...total, id: \.self) { paso in
                Capsule()
                    .fill(paso == actual ? Theme.Palette.brandAmber
                          : paso < actual ? Theme.Palette.brandBrown : Theme.Palette.stepPending)
                    .frame(width: paso == actual ? Theme.Size.stepDotActive : Theme.Size.stepDot,
                           height: Theme.Size.stepDot)
            }
        }
        .accessibilityHidden(true)
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
