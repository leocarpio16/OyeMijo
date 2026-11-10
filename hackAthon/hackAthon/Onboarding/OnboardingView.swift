//
//  OnboardingView.swift
//  hackAthon
//
//  Registro por voz, según las pantallas del equipo (Bienvenida, Nombre,
//  Contacto, Conectar, Permisos, Listo). Aparece solo si todavía no hay perfil.
//

import SwiftUI
import SwiftData

struct OnboardingView: View {
    @State private var modelo = OnboardingModel()
    @State private var eligiendoContacto = false
    @Environment(\.modelContext) private var context

    var body: some View {
        Group {
            switch modelo.paso {
            case .bienvenida:
                OnboardingHero(titulo: "Oye Mijo.",
                               texto: "Soy su nieto en el teléfono. Solo hábleme y yo le ayudo.",
                               boton: "Empezar", action: modelo.siguiente,
                               onLongPress: cargarEjemplo)
            case .nombre: pasoNombre
            case .contacto: pasoContacto
            case .conectar: pasoConectar
            case .permisos: pasoPermisos
            case .listo:
                OnboardingHero(titulo: "¡Listo, \(modelo.nombre)!",
                               texto: "Ya puede hablarme cuando quiera. Solo toque el botón y dígame qué necesita.",
                               boton: "Empezar",
                               height: Theme.Size.doneHeader, mijoSize: Theme.Size.doneMijo,
                               titleSize: Theme.Typography.doneSize) {
                    Task { await modelo.guardar(en: context) }
                }
            }
        }
        .animation(.easeInOut(duration: 0.25), value: modelo.paso)
        .task { await modelo.decirPregunta() }
    }

    // MARK: 1 · Nombre

    private var pasoNombre: some View {
        OnboardingStep(paso: 1, titulo: "¿Cómo le gusta que le diga?", subtitulo: "Dígamelo o escríbalo",
                       boton: "Siguiente",
                       botonActivo: !modelo.nombre.trimmingCharacters(in: .whitespaces).isEmpty,
                       onBack: modelo.anterior, onRepeat: repetir, onNext: modelo.siguiente,
                       onMic: { Task { await modelo.escucharNombre() } },
                       escuchando: modelo.voz.escuchando) {
            VStack(alignment: .leading, spacing: Theme.Spacing.l) {
                Text("Su nombre")
                    .font(Theme.Typography.fieldLabel)
                    .foregroundStyle(Theme.Palette.cafeSoft)
                TextField("Doña Mari", text: $modelo.nombre)
                    .serif(Theme.Typography.inputSize)
                    .foregroundStyle(Theme.Palette.cafe)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
                    .submitLabel(.done)
                    .padding(.horizontal, Theme.Spacing.l + 2)
                    .frame(minHeight: Theme.Size.input)
                    .background(Theme.Palette.cream, in: .rect(cornerRadius: Theme.Radius.input))
                    .overlay {
                        RoundedRectangle(cornerRadius: Theme.Radius.input)
                            .stroke(Theme.Palette.brandAmber, lineWidth: Theme.Size.inputBorder)
                    }
                    // La tarjeta está inclinada; la caja de texto se endereza para escribir cómodo.
                    .rotationEffect(.degrees(-TiltedCard<EmptyView>.tilt))
                if !modelo.nombre.isEmpty {
                    VStack(spacing: 0) {
                        Text("Así le voy a saludar:")
                            .foregroundStyle(Theme.Palette.cafeSoft)
                        Text("“\(saludo), \(modelo.nombre)”")
                            .bold()
                            .foregroundStyle(Theme.Palette.cafe)
                    }
                    .font(Theme.Typography.cardRow)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        // Mientras habla, el nombre se va escribiendo solo.
        .onChange(of: modelo.voz.textoEscuchado) { _, texto in
            if modelo.voz.escuchando { modelo.nombre = OnboardingModel.limpiarNombre(texto) }
        }
        // Si se queda callada 2 segundos, se toma como "ya terminé".
        .task(id: modelo.voz.textoEscuchado) {
            guard modelo.voz.escuchando, !modelo.voz.textoEscuchado.isEmpty else { return }
            try? await Task.sleep(for: .seconds(2))
            guard !Task.isCancelled else { return }
            modelo.terminarNombre()
        }
    }

    // MARK: 2 · Persona de confianza

    private var pasoContacto: some View {
        OnboardingStep(paso: 2, titulo: "¿A quién le aviso si me necesita?", subtitulo: "Su persona de confianza",
                       boton: "Siguiente", botonActivo: modelo.persona != nil,
                       onBack: modelo.anterior, onRepeat: repetir, onNext: modelo.siguiente) {
            VStack(spacing: Theme.Spacing.l) {
                if let persona = modelo.persona {
                    HStack(spacing: Theme.Spacing.m + 2) {
                        Text(String(persona.nombre.prefix(1)))
                            .serif(Theme.Typography.inputSize, weight: .semibold)
                            .foregroundStyle(Theme.Palette.cafe)
                            .frame(width: Theme.Size.contactAvatar, height: Theme.Size.contactAvatar)
                            .background(Theme.Palette.contactAvatar, in: .circle)
                        VStack(alignment: .leading, spacing: 0) {
                            Text(persona.nombre)
                                .font(Theme.Typography.contactName)
                                .foregroundStyle(Theme.Palette.cafe)
                            Text(persona.telefono)
                                .font(Theme.Typography.cardRow)
                                .foregroundStyle(Theme.Palette.cafeSoft)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        Image(systemName: "checkmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(Theme.Palette.surface)
                            .frame(width: Theme.Size.chip, height: Theme.Size.chip)
                            .background(Theme.Palette.taken, in: .circle)
                    }
                    .accessibilityElement(children: .combine)
                }
                Button { eligiendoContacto = true } label: {
                    Label(modelo.persona == nil ? "Elegir de mis contactos" : "Elegir otra persona",
                          systemImage: "person.crop.circle")
                        .font(Theme.Typography.textButton)
                        .foregroundStyle(Theme.Palette.cafe)
                        .frame(maxWidth: .infinity, minHeight: Theme.Size.cardButton)
                        .background(Theme.Palette.cream, in: .capsule)
                }
                .buttonStyle(.plain)
            }
        }
        .background {
            ContactPicker(isPresented: $eligiendoContacto) { persona in
                modelo.persona = persona
                Task { await modelo.voz.hablar("Muy bien. Si me necesita, le aviso a \(persona.nombre).") }
            }
        }
    }

    // MARK: 3 · Conectar a la familia

    private var pasoConectar: some View {
        let quien = modelo.persona?.nombre ?? "su familiar"
        return OnboardingStep(paso: 3, titulo: "Ahora conecte a \(quien)",
                              subtitulo: "Que escanee este código con su celular",
                              boton: "\(quien) ya lo hizo", botonIcono: "checkmark",
                              onBack: modelo.anterior, onRepeat: repetir,
                              onNext: {
                                  Task { await modelo.probarConexion() }
                                  modelo.siguiente()
                              }) {
            VStack(spacing: Theme.Spacing.l) {
                // Al escanearlo se abre la página de ntfy para recibir los avisos de Mijo.
                QRCode.imagen("https://ntfy.sh/\(modelo.tema)")?
                    .resizable()
                    .scaledToFit()
                    .frame(width: Theme.Size.qr, height: Theme.Size.qr)
                    .padding(Theme.Spacing.m + 2)
                    .background(Theme.Palette.surface, in: .rect(cornerRadius: Theme.Radius.input))
                    .overlay {
                        RoundedRectangle(cornerRadius: Theme.Radius.input)
                            .stroke(Theme.Palette.cardBack, lineWidth: 2)
                    }
                    .accessibilityLabel("Código para conectar a la familia")
                VStack(spacing: 2) {
                    Text("o que se suscriba en la app ntfy a:")
                        .font(Theme.Typography.cardRole)
                        .foregroundStyle(Theme.Palette.cafeSoft)
                    Text(modelo.tema)
                        .font(Theme.Typography.contactName)
                        .foregroundStyle(Theme.Palette.cafe)
                        .textSelection(.enabled)
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)
                }
            }
        }
    }

    // MARK: 4 · Permisos

    private var pasoPermisos: some View {
        let todo = modelo.microfonoListo && modelo.avisosListos
        return OnboardingStep(paso: 4, titulo: "Necesito 2 permisos", subtitulo: "Para escucharle y cuidarle",
                              boton: todo ? "Siguiente" : "Permitir todo",
                              onBack: modelo.anterior, onRepeat: repetir,
                              onNext: { Task { await modelo.permitirTodo() } }) {
            VStack(spacing: 0) {
                permiso("Micrófono", "Para escucharle", icono: "mic", listo: modelo.microfonoListo) {
                    Task { await modelo.permitirMicrofono() }
                }
                Rectangle().fill(Theme.Palette.cream).frame(height: 2)
                permiso("Avisos", "Para sus pastillas", icono: "bell", listo: modelo.avisosListos) {
                    Task { await modelo.permitirAvisos() }
                }
            }
        }
        .task { await modelo.revisarPermisos() }
    }

    private func permiso(_ titulo: String, _ para: String, icono: String, listo: Bool,
                         action: @escaping () -> Void) -> some View {
        HStack(spacing: Theme.Spacing.m) {
            Image(systemName: icono)
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(Theme.Palette.brandBrown)
                .frame(width: Theme.Size.rowIcon, height: Theme.Size.rowIcon)
                .background(Theme.Palette.cream, in: .circle)
            VStack(alignment: .leading, spacing: 0) {
                Text(titulo)
                    .font(Theme.Typography.rowTitle)
                    .foregroundStyle(Theme.Palette.cafe)
                Text(para)
                    .font(Theme.Typography.cardRole)
                    .foregroundStyle(Theme.Palette.cafeSoft)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            if listo {
                Label("Listo", systemImage: "checkmark")
                    .font(Theme.Typography.status)
                    .foregroundStyle(Theme.Palette.taken)
            } else {
                Button("Permitir", action: action)
                    .font(Theme.Typography.pillBold)
                    .foregroundStyle(Theme.Palette.cafe)
                    .padding(.horizontal, Theme.Spacing.l)
                    .frame(minHeight: Theme.Size.textButton)
                    .background(Theme.Palette.brandAmber, in: .capsule)
                    .buttonStyle(.plain)
            }
        }
        .padding(.vertical, Theme.Spacing.m)
    }

    // MARK: Ayudas

    private func repetir() {
        Task { await modelo.decirPregunta() }
    }

    /// "Buenos días" / "Buenas tardes" / "Buenas noches", como en Inicio.
    private var saludo: String {
        let hora = Calendar.current.component(.hour, from: .now)
        return hora < 12 ? "Buenos días" : hora < 19 ? "Buenas tardes" : "Buenas noches"
    }

    /// Para la demo: mantener presionado a Mijo en Bienvenida carga a doña Mari de ejemplo.
    private func cargarEjemplo() {
        modelo.voz.callar()
        SampleData.cargarSiEstaVacia(context)
        Task { await NotificationService.reprogramar(context) }
    }
}

#Preview {
    OnboardingView()
        .modelContainer(for: SampleData.modelos, inMemory: true)
}
