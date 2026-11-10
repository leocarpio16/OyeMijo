//
//  ComandosDeVoz.swift
//  hackAthon
//
//  Entiende las peticiones más comunes SIN IA, por palabras clave:
//  "ábreme Netflix", "ponme canciones de Pedro Infante", "dile a Leo que ya comí",
//  "recuérdame la pastilla de la presión a las 9 de la noche"…
//  Motivo: en las pruebas del iPhone la IA confundía las herramientas y se
//  quedaba pensando. Aquí la respuesta es siempre la misma y es inmediata.
//  Lo que no se reconoce aquí (plática) sí va con la IA (ver MijoAgent).
//

import Foundation

/// Lo que la persona pidió, ya entendido.
nonisolated enum Orden: Equatable {
    /// `hora` ya viene en formato de 24 horas.
    case recordatorio(paraQue: String, hora: Int, minuto: Int)
    /// Dijo "a las 9" sin decir si de la mañana o de la noche: hay que preguntar.
    case recordatorioSinPeriodo(paraQue: String, hora: Int, minuto: Int)
    case recordatorioSinHora
    /// WhatsApp a una persona. `texto` vacío si no dijo el mensaje.
    case mensaje(para: String, texto: String)
    /// Aviso a toda la familia (ntfy).
    case aviso(texto: String)
    case llamar(String)
    /// "Ya me la tomé": se anota.
    case pastillaTomada(paraQue: String)
    /// "Ya me tomé la pastilla": puede ser aviso o pregunta, se revisa antes de anotar.
    case pastillaDudosa(paraQue: String)
    case consultarPastillas
    /// `tipo`: desayuno, comida o cena.
    case comida(tipo: String, yaComio: Bool)
    case abrirApp(String)
    case appDesconocida
    case buscar(String)
    case dondeEstoy
}

nonisolated enum ComandosDeVoz {

    /// nil si la frase no es una petición conocida (entonces la contesta la IA).
    static func entender(_ frase: String) -> Orden? {
        // Dos listas parejas: las palabras como se dijeron ("presión") y sin acentos ("presion").
        let palabras = separar(frase)
        let planas = palabras.map(EmergencyRouter.normalizar)
        guard !planas.isEmpty else { return nil }
        let texto = " " + planas.joined(separator: " ") + " "
        let tiene = { (claves: [String]) in claves.contains { texto.contains(" \($0) ") } }
        let esPregunta = frase.contains("?") || tiene(pistasDePregunta)

        // 1. Recordatorio de pastilla
        if tiene(["recuerdame", "recordarme", "recordatorio", "acuerdame", "recuerdeme"]), tiene(pastilla) {
            let paraQue = paraQue(palabras, planas)
            guard let hora = hora(en: frase) else { return .recordatorioSinHora }
            if let exacta = hora.en24 {
                return .recordatorio(paraQue: paraQue, hora: exacta, minuto: hora.minuto)
            }
            return .recordatorioSinPeriodo(paraQue: paraQue, hora: hora.hora, minuto: hora.minuto)
        }

        // 2. ¿Dónde estoy?
        if tiene(["donde estoy", "mi direccion", "mi ubicacion", "donde me encuentro", "donde ando", "que direccion"]) {
            return .dondeEstoy
        }

        // 3. Mensaje a una persona (WhatsApp) o aviso a toda la familia
        if let inicio = planas.firstIndex(where: verbosDeMensaje.contains) {
            let que = planas[inicio...].firstIndex(of: "que")
            let destino = planas[(inicio + 1)..<(que ?? planas.count)].joined(separator: " ")
            let mensaje = que.map { mayuscula(palabras[($0 + 1)...].joined(separator: " ")) } ?? ""
            let aTodos = ["diles", "avisales", "mandales"].contains(planas[inicio])
                || destino.contains("familia") || destino.contains("todos")
            return aTodos ? .aviso(texto: mensaje) : .mensaje(para: destino, texto: mensaje)
        }

        // 4. Llamar
        if tiene(["llama a", "llama al", "marca a", "marca al", "llamale", "marcale", "hablale", "llamar a",
                  "marcar a", "comunicame", "hablar con", "llamada a"]) {
            return .llamar(planas.joined(separator: " "))
        }

        // 5. Pastillas: "ya me la tomé", "¿ya me tomé la pastilla?", "¿a qué hora me toca?"
        let seLaTomo = tiene(["ya me la tome", "ya me las tome", "ya la tome", "me acabo de tomar", "ya me la tome mijo"])
        let seTomo = tiene(["ya me tome", "ya tome", "me tome"])
        if seLaTomo || (seTomo && tiene(pastilla)) {
            if esPregunta { return .consultarPastillas }
            let cual = paraQue(palabras, planas)
            return seLaTomo ? .pastillaTomada(paraQue: cual) : .pastillaDudosa(paraQue: cual)
        }
        if tiene(pastilla), esPregunta || tiene(["me toca", "me tocan", "cuando", "cual", "cuales"]) {
            return .consultarPastillas
        }

        // 6. Comidas
        if tiene(["no he desayunado", "todavia no desayuno"]) { return .comida(tipo: "desayuno", yaComio: false) }
        if tiene(["no he comido", "todavia no como"]) { return .comida(tipo: "comida", yaComio: false) }
        if tiene(["no he cenado", "todavia no ceno"]) { return .comida(tipo: "cena", yaComio: false) }
        if tiene(["ya desayune"]) { return .comida(tipo: "desayuno", yaComio: true) }
        if tiene(["ya comi", "ya almorce"]) { return .comida(tipo: "comida", yaComio: true) }
        if tiene(["ya cene"]) { return .comida(tipo: "cena", yaComio: true) }

        // 7. Abrir una app o buscar algo en YouTube
        return appOBusqueda(palabras, planas)
    }

    /// Para la pregunta "¿de la mañana o de la noche?": true = tarde/noche, false = mañana.
    static func esDeTarde(_ frase: String) -> Bool? {
        let texto = " " + separar(frase).map(EmergencyRouter.normalizar).joined(separator: " ") + " "
        if ["noche", "tarde", " pm ", " p m "].contains(where: texto.contains) { return true }
        if ["manana", "madrugada", " am ", " a m "].contains(where: texto.contains) { return false }
        return nil
    }

    // MARK: Palabras clave (sin acentos y en minúsculas)

    private static let pastilla = ["pastilla", "pastillas", "pastillita", "medicina", "medicinas", "medicamento"]
    private static let pistasDePregunta = ["si ya", "sabes si", "dime si", "no se si", "no me acuerdo", "a que hora",
                                           "que pastilla", "que pastillas", "que medicina", "que medicinas"]
    private static let verbosDeMensaje: Set = ["mandale", "mandales", "manda", "mandar", "enviale", "envia", "dile",
                                               "diles", "escribele", "avisale", "avisales", "avisa"]
    private static let verbosDeAbrir = ["abreme", "abre", "abrir", "abra", "abrime", "abras"]
    private static let verbosDeBuscar = ["ponme", "pon", "poner", "ponga", "pongas", "quiero ver", "quiero escuchar",
                                         "quiero oir", "buscame", "busca", "buscar", "ensename", "muestrame"]
    private static let relleno: Set = ["la", "el", "los", "las", "app", "aplicacion", "de", "un", "una", "a", "en", "mi", "me"]
    /// Cómo se puede oír el nombre de cada app → nombre que entiende `MijoActions.abrirApp`.
    private static let apps: [(nombre: String, seOye: [String])] = [
        ("YouTube", ["youtube", "you tube", "yutub", "yutu"]),
        ("Netflix", ["netflix", "netflis", "net flix"]),
        ("WhatsApp", ["whatsapp", "whats app", "whats", "wats", "guasap", "wasap"]),
        ("Música", ["musica", "apple music"]),
        ("Mapas", ["mapas", "mapa", "maps"]),
        ("Spotify", ["spotify", "espotifai"]),
        ("Facebook", ["facebook", "face", "feis"]),
    ]

    // MARK: Ayudas

    /// "Mi hijo, ¡ábreme YouTube!" → ["ábreme", "YouTube"]: sin signos y sin
    /// el "oye Mijo" del principio (el micrófono suele oír "mi hijo").
    private static func separar(_ frase: String) -> [String] {
        var palabras = frase
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
        let saludos = [["oye"], ["hola"], ["mijo"], ["mijito"], ["mi", "hijo"], ["hijo"], ["por", "favor"]]
        while let saludo = saludos.first(where: { saludo in
            palabras.count > saludo.count && palabras.prefix(saludo.count).map { $0.lowercased() } == saludo
        }) {
            palabras.removeFirst(saludo.count)
        }
        return palabras
    }

    private static func mayuscula(_ texto: String) -> String {
        texto.prefix(1).uppercased() + texto.dropFirst()
    }

    /// "…la pastilla de la presión a las 9" → "la presión". Vacío si no dijo para qué es.
    private static func paraQue(_ palabras: [String], _ planas: [String]) -> String {
        guard let i = planas.firstIndex(where: pastilla.contains), i + 1 < planas.count,
              ["de", "del", "para"].contains(planas[i + 1]) else { return "" }
        let alto: Set = ["a", "todos", "todas", "cada", "diario", "en", "por", "hoy", "manana", "que", "y", "mijo"]
        let resto = palabras[(i + 2)...].prefix { !alto.contains(EmergencyRouter.normalizar($0)) }
        let texto = resto.joined(separator: " ")
        // "del azúcar" = "de el azúcar"
        return planas[i + 1] == "del" && !texto.isEmpty ? "el " + texto : texto
    }

    /// Hora dicha en la frase. `en24` es nil si falta saber si es de la mañana o de la noche.
    struct HoraDicha: Equatable {
        var hora: Int
        var minuto: Int
        var en24: Int?
    }

    static func hora(en frase: String) -> HoraDicha? {
        let texto = frase.lowercased()
        let plano = EmergencyRouter.normalizar(frase)
        var hora: Int?
        var minuto = 0
        let numeros = ["una": 1, "dos": 2, "tres": 3, "cuatro": 4, "cinco": 5, "seis": 6, "siete": 7,
                       "ocho": 8, "nueve": 9, "diez": 10, "once": 11, "doce": 12]
        if let m = texto.firstMatch(of: #/a las? (\d{1,2})(?:[:.](\d{2}))?/#) {
            hora = Int(m.1)
            minuto = m.2.flatMap { Int($0) } ?? 0
        } else if let m = texto.firstMatch(of: #/(\d{1,2})[:.](\d{2})/#) {
            hora = Int(m.1)
            minuto = Int(m.2) ?? 0
        } else if let m = plano.firstMatch(of: #/a las? (una|dos|tres|cuatro|cinco|seis|siete|ocho|nueve|diez|once|doce)\b/#) {
            hora = numeros[String(m.1)]
        } else if plano.contains("mediodia") {
            return HoraDicha(hora: 12, minuto: 0, en24: 12)
        }
        guard let hora, (0...23).contains(hora), (0...59).contains(minuto) else { return nil }
        if minuto == 0 {
            if plano.contains("y media") { minuto = 30 }
            if plano.contains("y cuarto") { minuto = 15 }
        }
        if hora > 12 || hora == 0 { return HoraDicha(hora: hora, minuto: minuto, en24: hora) }
        guard let tarde = esDeTarde(frase) else { return HoraDicha(hora: hora, minuto: minuto, en24: nil) }
        return HoraDicha(hora: hora, minuto: minuto, en24: en24(hora, tarde: tarde))
    }

    /// 9 de la noche → 21; 12 de la noche → 0; 12 del día → 12.
    static func en24(_ hora: Int, tarde: Bool) -> Int {
        if tarde { return hora < 12 ? hora + 12 : hora }
        return hora == 12 ? 0 : hora
    }

    private static func appOBusqueda(_ palabras: [String], _ planas: [String]) -> Orden? {
        let texto = planas.joined(separator: " ")
        // El verbo que aparezca primero manda: "ábreme…" abre, "ponme…" busca.
        func despues(de verbos: [String]) -> (inicio: Int, fin: Int)? {
            verbos.compactMap { verbo -> (Int, Int)? in
                let partes = verbo.split(separator: " ").map(String.init)
                guard partes.count <= planas.count else { return nil }
                return (0...(planas.count - partes.count))
                    .first { Array(planas[$0..<($0 + partes.count)]) == partes }
                    .map { ($0, $0 + partes.count) }
            }
            .min { $0.0 < $1.0 }
        }
        let abrir = despues(de: verbosDeAbrir)
        let buscar = despues(de: verbosDeBuscar)
        guard let verbo = [abrir, buscar].compactMap({ $0 }).min(by: { $0.inicio < $1.inicio }) else { return nil }
        let esAbrir = abrir?.inicio == verbo.inicio

        // Lo que pidió, sin "la app de…" al principio ni "en YouTube / por favor" al final.
        var desde = verbo.fin
        while desde < planas.count, relleno.contains(planas[desde]) { desde += 1 }
        var hasta = planas.count
        if hasta - desde >= 2, planas[hasta - 2] == "por", planas[hasta - 1] == "favor" { hasta -= 2 }
        if hasta - desde >= 3, planas[hasta - 2] == "en", planas[hasta - 1] == "youtube" { hasta -= 2 }
        guard desde < hasta else { return esAbrir ? .appDesconocida : nil }
        let pedido = planas[desde..<hasta].joined(separator: " ")

        if let app = apps.first(where: { $0.seOye.contains(pedido) }) { return .abrirApp(app.nombre) }
        if esAbrir {
            let app = apps.first { $0.seOye.contains { (" " + texto + " ").contains(" \($0) ") } }
            return app.map { .abrirApp($0.nombre) } ?? .appDesconocida
        }
        // "Ponme un recordatorio…" no es para YouTube.
        guard !["recordatorio", "alarma", "pastilla"].contains(where: pedido.contains) else { return nil }
        return .buscar(palabras[desde..<hasta].joined(separator: " "))
    }
}
