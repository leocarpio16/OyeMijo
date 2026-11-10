//
//  MijoTools.swift
//  hackAthon
//
//  Las "herramientas" que la IA (Foundation Models) puede usar. Cada una
//  le dice al modelo qué hace y qué datos necesita; el modelo decide cuál
//  llamar según lo que pidió la persona. El trabajo real está en MijoActions.
//  El texto que regresa cada herramienta lo lee la IA, no la persona.
//

import Foundation
import FoundationModels

nonisolated struct LlamarFamiliarTool: Tool {
    let acciones: MijoActions
    let name = "llamarFamiliar"
    let description = "Prepara una llamada a un familiar cuando la persona pide hablar con alguien."

    @Generable
    struct Arguments {
        @Guide(description: "Nombre o parentesco del familiar, por ejemplo: Leo, mi hija")
        var familiar: String
    }

    func call(arguments: Arguments) async throws -> String {
        await acciones.llamar(a: arguments.familiar)
    }
}

nonisolated struct MandarWhatsAppTool: Tool {
    let acciones: MijoActions
    let name = "mandarWhatsApp"
    let description = "Deja listo un mensaje de WhatsApp para un familiar cuando la persona pide mandarle un mensaje o decirle algo."

    @Generable
    struct Arguments {
        @Guide(description: "Nombre o parentesco del familiar, por ejemplo: Leo, mi hija")
        var familiar: String
        @Guide(description: "El mensaje tal como lo leerá el familiar, escrito como si lo dijera la persona mayor, por ejemplo: Hijo, ¿vienes a comer el domingo?")
        var mensaje: String
    }

    func call(arguments: Arguments) async throws -> String {
        await acciones.mandarWhatsApp(a: arguments.familiar, texto: arguments.mensaje)
    }
}

nonisolated struct AvisarFamiliaTool: Tool {
    let acciones: MijoActions
    let name = "avisarFamilia"
    let description = "Manda un aviso al teléfono de toda su familia, cuando la persona pide avisarle a su familia o a todos, sin nombrar a una sola persona."

    @Generable
    struct Arguments {
        @Guide(description: "El aviso tal como lo leerá la familia, escrito como si lo dijera la persona mayor, por ejemplo: Ya llegué a mi casa")
        var mensaje: String
    }

    func call(arguments: Arguments) async throws -> String {
        await acciones.avisarFamilia(texto: arguments.mensaje)
    }
}

nonisolated struct AbrirAppTool: Tool {
    let acciones: MijoActions
    let name = "abrirApp"
    let description = "Abre otra app del teléfono cuando la persona la pide, por ejemplo: ábreme Netflix."

    @Generable
    struct Arguments {
        @Guide(description: "Nombre de la app", .anyOf(["YouTube", "Netflix", "WhatsApp", "Música", "Mapas", "Spotify", "Facebook"]))
        var app: String
    }

    func call(arguments: Arguments) async throws -> String {
        await acciones.abrirApp(arguments.app)
    }
}

nonisolated struct BuscarEnYouTubeTool: Tool {
    let acciones: MijoActions
    let name = "buscarEnYouTube"
    let description = "Busca videos en YouTube cuando la persona quiere ver o escuchar algo en particular, por ejemplo: ponme canciones de Pedro Infante."

    @Generable
    struct Arguments {
        @Guide(description: "Qué buscar, corto, por ejemplo: canciones de Pedro Infante, receta de mole")
        var busqueda: String
    }

    func call(arguments: Arguments) async throws -> String {
        await acciones.buscarEnYouTube(arguments.busqueda)
    }
}

nonisolated struct CrearRecordatorioMedicinaTool: Tool {
    let acciones: MijoActions
    let name = "crearRecordatorioMedicina"
    let description = "Guarda un recordatorio para tomar una pastilla o medicina a una hora."

    @Generable
    struct Arguments {
        @Guide(description: "Para qué es la pastilla, con artículo, por ejemplo: la presión, el azúcar")
        var paraQue: String
        @Guide(description: "Hora en formato de 24 horas", .range(0...23))
        var hora: Int
        @Guide(description: "Minuto", .range(0...59))
        var minuto: Int
    }

    func call(arguments: Arguments) async throws -> String {
        await acciones.crearRecordatorio(paraQue: arguments.paraQue, hora: arguments.hora, minuto: arguments.minuto)
    }
}

nonisolated struct ConsultarMedicinaTool: Tool {
    let acciones: MijoActions
    let name = "consultarMedicina"
    let description = "Dice a qué hora le toca una pastilla y si ya se la tomó hoy."

    @Generable
    struct Arguments {
        @Guide(description: "Para qué es la pastilla, por ejemplo: la presión. Vacío para todas.")
        var paraQue: String
    }

    func call(arguments: Arguments) async throws -> String {
        await acciones.consultarMedicinas(paraQue: arguments.paraQue)
    }
}

nonisolated struct RegistrarComidaTool: Tool {
    let acciones: MijoActions
    let name = "registrarComida"
    let description = "Anota si la persona ya desayunó, comió o cenó."

    @Generable
    struct Arguments {
        @Guide(description: "Cuál comida", .anyOf(["desayuno", "comida", "cena"]))
        var tipo: String
        @Guide(description: "true si ya comió, false si todavía no")
        var yaComio: Bool
    }

    func call(arguments: Arguments) async throws -> String {
        guard let tipo = TipoComida(rawValue: arguments.tipo) else {
            return "No entendí cuál comida. Pregúntale si fue desayuno, comida o cena."
        }
        return await acciones.registrarComida(tipo, yaComio: arguments.yaComio)
    }
}

nonisolated struct MarcarTomadaTool: Tool {
    let acciones: MijoActions
    let name = "marcarMedicinaTomada"
    let description = "Anota que la persona ya se tomó una pastilla, cuando ella lo dice."

    @Generable
    struct Arguments {
        @Guide(description: "Para qué es la pastilla, por ejemplo: la presión")
        var paraQue: String
    }

    func call(arguments: Arguments) async throws -> String {
        await acciones.marcarTomada(paraQue: arguments.paraQue)
    }
}
