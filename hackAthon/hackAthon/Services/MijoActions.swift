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

    init(context: ModelContext) {
        self.context = context
    }

    func limpiar() {
        detalle = nil
        etiquetas = []
        accion = nil
    }

    // MARK: Familia

    func llamar(a nombre: String) -> String {
        let familia = (try? context.fetch(FetchDescriptor<Familiar>())) ?? []
        let buscado = EmergencyRouter.normalizar(nombre)
        // Ojo: un texto vacío "está contenido" en cualquier frase; por eso se revisa que no esté vacío.
        let coincide = { (dato: String) in
            let dato = EmergencyRouter.normalizar(dato)
            return !dato.isEmpty && buscado.contains(dato)
        }
        // Si solo hay una persona de confianza, "llama a mi hija" es ella.
        let encontrado = familia.first { coincide($0.nombre) || coincide($0.parentesco) }
            ?? (familia.count == 1 ? familia.first : nil)
        guard let familiar = encontrado else {
            let nombres = familia.map(\.nombre).joined(separator: ", ")
            return "No hay nadie con ese nombre. Familiares guardados: \(nombres)."
        }
        accion = .llamar(familiar)
        etiquetas = familiar.parentesco.isEmpty ? [familiar.nombre] : [familiar.nombre, "Su \(familiar.parentesco)"]
        return "Listo: en cuanto termines de hablar se abre la llamada a \(familiar.nombre). Dile que ya le estás marcando."
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

    func crearRecordatorio(paraQue: String, hora: Int, minuto: Int) -> String {
        guard (0...23).contains(hora), (0...59).contains(minuto) else {
            return "La hora no es válida. Pregúntale a qué hora la quiere."
        }
        let horario = Horario(hora: hora, minuto: minuto)
        let medicina: Medicina
        if let existente = buscarMedicina(paraQue) {
            medicina = existente
            if !medicina.horarios.contains(horario) { medicina.horarios.append(horario) }
        } else {
            medicina = Medicina(nombre: "Pastilla", dosis: "", paraQue: paraQue, horarios: [horario])
            context.insert(medicina)
        }
        try? context.save()
        // Que la nueva hora también tenga su notificación con la voz de Mijo.
        let context = self.context
        Task { await NotificationService.reprogramar(context) }
        etiquetas = [etiqueta(de: medicina), horario.texto]
        return "Recordatorio guardado: pastilla de \(medicina.paraQue) a las \(horario.texto)."
    }

    /// Estado de hoy de una medicina (o de todas si `paraQue` viene vacío).
    func consultarMedicinas(paraQue: String) -> String {
        let todas = (try? context.fetch(FetchDescriptor<Medicina>())) ?? []
        guard !todas.isEmpty else { return "No tiene medicinas guardadas." }

        if let medicina = buscarMedicina(paraQue) {
            etiquetas = [etiqueta(de: medicina)]
            detalle = cuantoFalta(medicina)
            accion = .marcarTomada(medicina)
            return estado(de: medicina)
        }
        return todas.map(estado(de:)).joined(separator: " ")
    }

    /// Cuando lo dice por voz: "ya me tomé la de la presión".
    func marcarTomada(paraQue: String) -> String {
        guard let medicina = buscarMedicina(paraQue) else {
            let todas = (try? context.fetch(FetchDescriptor<Medicina>())) ?? []
            let lista = todas.map { "la de \($0.paraQue)" }.joined(separator: " o ")
            return "No sé cuál pastilla fue. Pregúntale si fue \(lista)."
        }
        marcarTomada(medicina)
        etiquetas = [etiqueta(de: medicina)]
        return "Anotado: ya se tomó la pastilla de \(medicina.paraQue)."
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
