//
//  MijoActions.swift
//  hackAthon
//
//  Lo que Mijo sabe HACER con los datos del teléfono: buscar a un familiar,
//  guardar un recordatorio de medicina, revisar si ya se la tomó, anotar una
//  comida. La IA no toca la base de datos: solo elige cuál de estas funciones
//  usar (ver MijoTools.swift) y aquí se hace el trabajo.
//

import Foundation
import SwiftData

/// Botón que la pantalla de respuesta ofrece después de hablar con Mijo.
enum AccionDeMijo {
    /// Mijo marca solo al terminar de hablar; el botón "Llamar a Leo" queda de respaldo.
    case llamar(Familiar)
    /// "Ya me la tomé".
    case marcarTomada(Medicina)
    /// Mijo abre WhatsApp con el mensaje ya escrito; la persona solo toca Enviar.
    case mandarMensaje(Familiar, texto: String)
    /// Abre otra app (YouTube, Netflix…). Si no está instalada, su página web.
    case abrirApp(nombre: String, url: URL, web: URL)
}

/// Apps que Mijo sabe abrir, con la pista corta que dice al abrirlas.
struct AppConocida {
    let nombre: String
    let url: String
    let web: String
    let pista: String

    static let todas = [
        AppConocida(nombre: "YouTube", url: "youtube://", web: "https://www.youtube.com",
                    pista: "Toque el video que quiera ver."),
        AppConocida(nombre: "Netflix", url: "nflx://", web: "https://www.netflix.com",
                    pista: "Toque la película o serie que quiera ver y luego Reproducir."),
        AppConocida(nombre: "WhatsApp", url: "whatsapp://", web: "https://web.whatsapp.com",
                    pista: "Toque el nombre de la persona con quien quiere platicar."),
        AppConocida(nombre: "Música", url: "music://", web: "https://music.apple.com",
                    pista: "Toque la canción que quiera escuchar."),
        AppConocida(nombre: "Mapas", url: "maps://", web: "https://maps.apple.com",
                    pista: "Toque arriba donde dice Buscar y escriba a dónde quiere ir."),
        AppConocida(nombre: "Spotify", url: "spotify://", web: "https://open.spotify.com",
                    pista: "Toque la canción que quiera escuchar."),
        AppConocida(nombre: "Facebook", url: "fb://", web: "https://www.facebook.com",
                    pista: "Deslice el dedo hacia arriba para ver más."),
    ]
}

/// Lo que se muestra en "Mijo le contesta".
struct RespuestaDeMijo {
    var texto: String
    /// Renglón gris debajo: "Faltan 20 minutos".
    var detalle: String?
    /// Etiquetas: "Losartán 50 mg".
    var etiquetas: [String] = []
    var accion: AccionDeMijo?
}

final class MijoActions {
    private let context: ModelContext

    // Lo que dejó la última herramienta para la pantalla. Se limpia en cada pregunta.
    private(set) var detalle: String?
    private(set) var etiquetas: [String] = []
    private(set) var accion: AccionDeMijo?
    /// Lo que Mijo le dice a la persona, ya redactado (sin pasar por la IA).
    /// Lo que regresa cada función es otra cosa: es el texto para la IA.
    private(set) var frase: String?

    init(context: ModelContext) {
        self.context = context
    }

    func limpiar() {
        detalle = nil
        etiquetas = []
        accion = nil
        frase = nil
    }

    // MARK: Familia

    func llamar(a nombre: String) async -> String {
        guard let familiar = await buscarPersona(nombre) else { return noEncontrado() }
        accion = .llamar(familiar)
        etiquetas = etiquetas(de: familiar)
        frase = "Claro, ahorita le marco a \(familiar.nombre)."
        return "Listo: en cuanto termines de hablar se abre la llamada a \(familiar.nombre). Dile que ya le estás marcando."
    }

    func mandarWhatsApp(a nombre: String, texto: String) async -> String {
        let texto = texto.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let familiar = await buscarPersona(nombre) else {
            // No está en Mijo ni en sus contactos (o no dio permiso): WhatsApp se abre
            // con el mensaje escrito y la persona toca a quién mandárselo.
            guard !texto.isEmpty else { return noEncontrado() }
            var app = URLComponents(string: "whatsapp://send")!
            var web = URLComponents(string: "https://wa.me/")!
            app.queryItems = [.init(name: "text", value: texto)]
            web.queryItems = app.queryItems
            guard let url = app.url, let urlWeb = web.url else { return noEncontrado() }
            accion = .abrirApp(nombre: "WhatsApp", url: url, web: urlWeb)
            detalle = "“\(texto)”"
            etiquetas = ["WhatsApp"]
            frase = "Le abro WhatsApp con el mensaje ya escrito. Toque el nombre de la persona y luego Enviar."
            return "Listo."
        }
        guard !texto.isEmpty else {
            frase = "¿Qué le quiere decir a \(familiar.nombre)? Dígame, por ejemplo: dile a \(familiar.nombre) que ya comí."
            return "Falta el mensaje. Pregúntale qué le quiere decir a \(familiar.nombre)."
        }
        frase = "Listo. Le dejé el mensaje para \(familiar.nombre) ya escrito. Solo toque el botón verde de Enviar."
        accion = .mandarMensaje(familiar, texto: texto)
        detalle = "“\(texto)”"
        etiquetas = [familiar.nombre, "WhatsApp"]
        return "Listo: en cuanto termines de hablar se abre WhatsApp con el mensaje para \(familiar.nombre) ya escrito. Dile que solo toque el botón verde de Enviar."
    }

    /// Aviso por ntfy a toda la familia, sin que la persona toque nada.
    func avisarFamilia(texto: String) async -> String {
        let texto = texto.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !texto.isEmpty else {
            frase = "¿Qué le quiere avisar a su familia? Dígame, por ejemplo: avísale a mi familia que ya llegué."
            return "Falta el aviso. Pregúntale qué le quiere decir a su familia."
        }
        guard let datos = datosParaAvisar(), !datos.tema.isEmpty else {
            frase = "Su familia todavía no está conectada a Mijo."
            return "Su familia todavía no está conectada a Mijo. Dile que le pida a su familia escanear el código de Mijo."
        }
        let enviado = await NtfyService.avisar(tema: datos.tema, titulo: "Mensaje de \(datos.nombre)",
                                               mensaje: texto, prioridad: .alta, etiquetas: ["speech_balloon"])
        guard enviado else {
            frase = "No pude mandar el aviso porque no hay internet. Inténtelo en un rato."
            return "No se pudo mandar el aviso: no hay internet. Dile que lo intente en un rato."
        }
        frase = "Listo, ya le avisé a su familia."
        detalle = "“\(texto)”"
        etiquetas = ["Aviso enviado"]
        return "Listo: el aviso ya le llegó a su familia."
    }

    // MARK: Ubicación

    func decirDireccion() async -> String {
        guard let ubicacion = await LocationService.ubicacionActual(),
              let direccion = ubicacion.direccionCorta else {
            frase = "No pude saber dónde está. Revise que haya señal y que la ubicación esté permitida."
            return "No pude saber la dirección: no hay señal o falta el permiso de ubicación. Dile que le pregunte a su familia."
        }
        etiquetas = ["Su ubicación"]
        detalle = ubicacion.direccion
        frase = "Usted está en \(direccion)."
        return "La persona está en: \(direccion)."
    }

    // MARK: Otras apps

    func abrirApp(_ nombre: String) -> String {
        let buscado = EmergencyRouter.normalizar(nombre)
        guard let app = AppConocida.todas.first(where: { EmergencyRouter.normalizar($0.nombre) == buscado }),
              let url = URL(string: app.url), let web = URL(string: app.web) else {
            let nombres = AppConocida.todas.map(\.nombre).joined(separator: ", ")
            frase = "Esa aplicación no la sé abrir. Sé abrir \(nombres)."
            return "Esa app no la sé abrir. Solo sé abrir: \(nombres)."
        }
        accion = .abrirApp(nombre: app.nombre, url: url, web: web)
        etiquetas = [app.nombre]
        detalle = app.pista
        frase = "Ahorita le abro \(app.nombre). \(app.pista)"
        return "Listo: en cuanto termines de hablar se abre \(app.nombre). Dile esta pista: \(app.pista)"
    }

    func buscarEnYouTube(_ texto: String) -> String {
        let texto = texto.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !texto.isEmpty else { return "Falta qué buscar. Pregúntale qué quiere ver." }
        var app = URLComponents(string: "youtube://results")!
        var web = URLComponents(string: "https://www.youtube.com/results")!
        app.queryItems = [.init(name: "search_query", value: texto)]
        web.queryItems = app.queryItems
        guard let url = app.url, let urlWeb = web.url else { return "No pude armar la búsqueda." }
        accion = .abrirApp(nombre: "YouTube", url: url, web: urlWeb)
        etiquetas = ["YouTube", texto]
        detalle = "Toque el video que quiera ver."
        frase = "Ahorita le pongo \(texto) en YouTube. Toque el video que quiera ver."
        return "Listo: en cuanto termines de hablar se abre YouTube con videos de \(texto). Dile que toque el video que quiera ver."
    }

    // MARK: Familia (ayudas)

    /// Primero entre sus familiares de Mijo; si no está, en los contactos del teléfono.
    /// Un contacto encontrado no se guarda en Mijo: solo se usa para esta llamada o mensaje.
    private func buscarPersona(_ nombre: String) async -> Familiar? {
        if let familiar = buscarFamiliar(nombre) { return familiar }
        guard let contacto = await ContactsService.buscar(nombre) else { return nil }
        return Familiar(nombre: contacto.nombre, parentesco: "", telefono: contacto.telefono)
    }

    /// "Leo", "mi hijo", "a Leo": busca por nombre o parentesco.
    private func buscarFamiliar(_ nombre: String) -> Familiar? {
        let familia = (try? context.fetch(FetchDescriptor<Familiar>())) ?? []
        let buscado = EmergencyRouter.normalizar(nombre)
        // Ojo: un texto vacío "está contenido" en cualquier frase; por eso se revisa que no esté vacío.
        let coincide = { (dato: String) in
            let dato = EmergencyRouter.normalizar(dato)
            // Guardado como "Leo Carpio" pero le dicen "Leo": también vale el primer nombre.
            let primero = dato.split(separator: " ").first.map(String.init) ?? ""
            let palabras = buscado.split(separator: " ").map(String.init)
            return !dato.isEmpty && (buscado.contains(dato) || (primero.count >= 3 && palabras.contains(primero)))
        }
        // Si solo hay una persona de confianza, "llama a mi hija" es ella.
        // Pero si dijo otro nombre ("dile a Pedro"), no se le manda a ella por error.
        let parentescos = ["hijo", "hija", "nieto", "nieta", "esposo", "esposa", "hermano", "hermana",
                           "sobrino", "sobrina", "familia", "familiar", "contacto", "persona"]
        let porParentesco = buscado.split(separator: " ").contains { parentescos.contains(String($0)) }
        return familia.first { coincide($0.nombre) || coincide($0.parentesco) }
            ?? (familia.count == 1 && porParentesco ? familia.first : nil)
    }

    private func noEncontrado() -> String {
        frase = "No encontré a esa persona en sus contactos. ¿Me dice su nombre otra vez?"
        let familia = (try? context.fetch(FetchDescriptor<Familiar>())) ?? []
        let nombres = familia.map(\.nombre).joined(separator: ", ")
        return "No hay nadie con ese nombre. Familiares guardados: \(nombres)."
    }

    private func etiquetas(de familiar: Familiar) -> [String] {
        familiar.parentesco.isEmpty ? [familiar.nombre] : [familiar.nombre, "Su \(familiar.parentesco)"]
    }

    /// A quién se llama primero en una emergencia.
    func familiarPrincipal() -> Familiar? {
        let familia = (try? context.fetch(FetchDescriptor<Familiar>())) ?? []
        return familia.first(where: \.esPrincipal) ?? familia.first
    }

    /// Tema de ntfy de la familia y cómo se llama la persona, para los avisos.
    func datosParaAvisar() -> (tema: String, nombre: String)? {
        guard let ajustes = try? context.fetch(FetchDescriptor<Ajustes>()).first else { return nil }
        return (ajustes.temaNtfy, ajustes.comoLlamarla)
    }

    /// Datos para quien llegue a ayudar (familia, paramédicos).
    func fichaMedica() -> FichaMedica? {
        try? context.fetch(FetchDescriptor<FichaMedica>()).first
    }

    // MARK: Medicinas

    /// `nombre` y `dosis` llegan desde la pantalla "Agregar pastilla"; por voz van vacíos.
    func crearRecordatorio(paraQue: String, hora: Int, minuto: Int, nombre: String = "", dosis: String = "") -> String {
        guard (0...23).contains(hora), (0...59).contains(minuto) else {
            frase = "No entendí la hora. ¿A qué hora le recuerdo su pastilla?"
            return "La hora no es válida. Pregúntale a qué hora la quiere."
        }
        let horario = Horario(hora: hora, minuto: minuto)
        let medicina: Medicina
        // "Recuérdame la pastilla a las 9" sin decir de qué: solo se acepta si tiene una sola.
        let sinNombre = paraQue.trimmingCharacters(in: .whitespaces).isEmpty
        if sinNombre, unicaMedicina() == nil {
            frase = "¿Para qué es la pastilla? Dígame, por ejemplo: recuérdame la pastilla de la presión a las nueve de la noche."
            return "Falta saber para qué es la pastilla. Pregúntale."
        }
        if let existente = sinNombre ? unicaMedicina() : buscarMedicina(paraQue) {
            medicina = existente
            if !medicina.horarios.contains(horario) { medicina.horarios.append(horario) }
            if !nombre.isEmpty { medicina.nombre = nombre }
            if !dosis.isEmpty { medicina.dosis = dosis }
        } else {
            medicina = Medicina(nombre: nombre.isEmpty ? "Pastilla" : nombre, dosis: dosis,
                                paraQue: paraQue, horarios: [horario])
            context.insert(medicina)
        }
        try? context.save()
        // Que la nueva hora también tenga su notificación con la voz de Mijo.
        let context = self.context
        Task { await NotificationService.reprogramar(context) }
        etiquetas = [etiqueta(de: medicina), horario.texto]
        frase = "Listo. Le voy a recordar su pastilla de \(medicina.paraQue) a las \(horario.texto)."
        return "Recordatorio guardado: pastilla de \(medicina.paraQue) a las \(horario.texto)."
    }

    /// Estado de hoy de una medicina (o de todas si `paraQue` viene vacío).
    func consultarMedicinas(paraQue: String) -> String {
        let todas = (try? context.fetch(FetchDescriptor<Medicina>())) ?? []
        guard !todas.isEmpty else {
            frase = Self.sinPastillas
            return "No tiene medicinas guardadas."
        }
        frase = YaMeTomeLaPastillaIntent.estado()

        if let medicina = buscarMedicina(paraQue) ?? unicaMedicina() {
            etiquetas = [etiqueta(de: medicina)]
            detalle = cuantoFalta(medicina)
            accion = .marcarTomada(medicina)
            return estado(de: medicina)
        }
        return todas.map(estado(de:)).joined(separator: " ")
    }

    /// Cuando lo dice por voz: "ya me tomé la de la presión".
    func marcarTomada(paraQue: String) -> String {
        guard let medicina = buscarMedicina(paraQue) ?? unicaMedicina() else {
            let todas = (try? context.fetch(FetchDescriptor<Medicina>())) ?? []
            let lista = todas.map { "la de \($0.paraQue)" }.joined(separator: " o ")
            frase = todas.isEmpty ? Self.sinPastillas : "¿Cuál pastilla se tomó: \(lista)?"
            return "No sé cuál pastilla fue. Pregúntale si fue \(lista)."
        }
        marcarTomada(medicina)
        etiquetas = [etiqueta(de: medicina)]
        frase = "Muy bien, ya lo anoté. Su pastilla de \(medicina.paraQue) está tomada."
        return "Anotado: ya se tomó la pastilla de \(medicina.paraQue)."
    }

    /// "Ya me tomé la pastilla" puede ser un aviso o una pregunta (la voz no trae signos).
    /// Si hoy ya está anotada, se lo dice. Si no, regresa la medicina para que Mijo
    /// pregunte "¿Ya se la tomó?" antes de anotar nada.
    func revisarToma(paraQue: String) -> Medicina? {
        guard let medicina = buscarMedicina(paraQue) ?? unicaMedicina() else {
            _ = consultarMedicinas(paraQue: "")
            return nil
        }
        etiquetas = [etiqueta(de: medicina)]
        if let ultima = tomasDeHoy(medicina).compactMap(\.respondida).max() {
            let hora = ultima.formatted(.dateTime.hour().minute().locale(Locale(identifier: "es_MX")))
            frase = "Sí, ya la tengo anotada. Se tomó la pastilla de \(medicina.paraQue) a las \(hora)."
            return nil
        }
        accion = .marcarTomada(medicina)
        frase = "Todavía no la tengo anotada. ¿Ya se tomó la pastilla de \(medicina.paraQue)?"
        return medicina
    }

    static let sinPastillas = "No tiene pastillas guardadas todavía. Dígame, por ejemplo: recuérdame la pastilla de la presión a las nueve de la noche."

    /// Si solo tiene una medicina, "la pastilla" es esa.
    private func unicaMedicina() -> Medicina? {
        let todas = (try? context.fetch(FetchDescriptor<Medicina>())) ?? []
        return todas.count == 1 ? todas.first : nil
    }

    /// Anota la toma que toca ahora (o, si no hay, la de esta hora).
    func marcarTomada(_ medicina: Medicina) {
        let horario = medicina.horarioPorConfirmar() ?? Horario(de: .now)
        context.insert(Toma(medicina: medicina, programada: horario.fechaDeHoy,
                            estado: .tomada, respondida: .now))
        try? context.save()
    }

    // MARK: Comidas

    func registrarComida(_ tipo: TipoComida, yaComio: Bool) -> String {
        context.insert(Comida(tipo: tipo, yaComio: yaComio))
        try? context.save()
        frase = yaComio ? "Qué bueno. Ya anoté su \(tipo.rawValue)." : "Está bien, ya lo anoté. Procure comer algo pronto, le hace bien."
        return yaComio ? "Anotado: ya tomó su \(tipo.rawValue)." : "Anotado: todavía no toma su \(tipo.rawValue)."
    }

    // MARK: Ayudas

    private func buscarMedicina(_ paraQue: String) -> Medicina? {
        let buscado = EmergencyRouter.normalizar(paraQue)
        guard !buscado.isEmpty else { return nil }
        let todas = (try? context.fetch(FetchDescriptor<Medicina>())) ?? []
        return todas.first {
            // "la presión" → "presion": se compara sin el artículo.
            let para = EmergencyRouter.normalizar($0.paraQue).split(separator: " ").last.map(String.init) ?? ""
            let nombre = EmergencyRouter.normalizar($0.nombre)
            return (!para.isEmpty && buscado.contains(para)) || (nombre != "pastilla" && buscado.contains(nombre))
        }
    }

    /// "Losartán 50 mg" o, si no se sabe el nombre, "Pastilla de la presión".
    private func etiqueta(de medicina: Medicina) -> String {
        medicina.dosis.isEmpty ? "Pastilla de \(medicina.paraQue)" : "\(medicina.nombre) \(medicina.dosis)"
    }

    private func tomasDeHoy(_ medicina: Medicina) -> [Toma] {
        medicina.tomas.filter { $0.estado == .tomada && Calendar.current.isDateInToday($0.respondida ?? $0.programada) }
    }

    /// Texto para la IA: horarios, si ya la tomó hoy y cuándo le toca.
    private func estado(de medicina: Medicina) -> String {
        let horarios = medicina.horarios.sorted().map(\.texto).joined(separator: " y ")
        var texto = "Pastilla de \(medicina.paraQue) (\(etiqueta(de: medicina))): le toca a las \(horarios)."
        if let ultima = tomasDeHoy(medicina).compactMap(\.respondida).max() {
            let hora = ultima.formatted(.dateTime.hour().minute().locale(Locale(identifier: "es_MX")))
            texto += " Hoy ya la tomó a las \(hora)."
        } else {
            texto += " Hoy todavía no ha confirmado que la tomó."
        }
        if let siguiente = medicina.siguienteHorario() {
            texto += " La siguiente es a las \(siguiente.texto)."
        } else {
            texto += " Hoy ya no le toca otra."
        }
        return texto
    }

    /// "Faltan 20 minutos", "Faltan 3 horas" o nil si hoy ya no le toca.
    private func cuantoFalta(_ medicina: Medicina) -> String? {
        guard let siguiente = medicina.siguienteHorario() else { return nil }
        let ahora = Calendar.current.dateComponents([.hour, .minute], from: .now)
        let minutos = siguiente.minutosDelDia - ((ahora.hour ?? 0) * 60 + (ahora.minute ?? 0))
        if minutos < 60 { return minutos == 1 ? "Falta 1 minuto" : "Faltan \(minutos) minutos" }
        let horas = Int((Double(minutos) / 60).rounded())
        return horas == 1 ? "Falta 1 hora" : "Faltan \(horas) horas"
    }
}
