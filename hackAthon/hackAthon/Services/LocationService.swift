//
//  LocationService.swift
//  hackAthon
//
//  Dónde está la persona: lee el GPS una vez y lo convierte en dirección
//  ("Av. Insurgentes Sur 123, Del Valle") con MapKit. Se usa en una caída
//  o al pedir ayuda (va en el aviso de ntfy y Mijo la dice en voz) y cuando
//  pregunta "¿dónde estoy?".
//

import CoreLocation
import MapKit

struct Ubicacion {
    /// Dirección completa, para el aviso a la familia.
    let direccion: String?
    /// Más corta, para decirla en voz.
    let direccionCorta: String?
    /// Enlace a Apple Maps con el punto exacto.
    let mapa: URL
}

enum LocationService {

    static var sinPreguntar: Bool {
        CLLocationManager().authorizationStatus == .notDetermined
    }

    static var permitido: Bool {
        let estado = CLLocationManager().authorizationStatus
        return estado == .authorizedWhenInUse || estado == .authorizedAlways
    }

    /// Pide permiso si todavía no se ha preguntado y regresa dónde está.
    /// nil si no dio permiso, no hay señal o tarda más de `segundos`.
    static func ubicacionActual(segundos: Int = 10) async -> Ubicacion? {
        guard let lugar = await primeraLectura(segundos: segundos) else { return nil }
        let direccion = await direccion(de: lugar)
        // Enlace de Google Maps: abre igual en Android, iPhone o computadora (la familia puede no tener iPhone).
        var mapa = URLComponents(string: "https://www.google.com/maps/search/")!
        let punto = lugar.coordinate
        mapa.queryItems = [.init(name: "api", value: "1"),
                           .init(name: "query", value: "\(punto.latitude),\(punto.longitude)")]
        guard let url = mapa.url else { return nil }
        return Ubicacion(direccion: direccion?.completa, direccionCorta: direccion?.corta, mapa: url)
    }

    /// La primera lectura del GPS, con tiempo límite: en una emergencia no se puede esperar de más.
    private static func primeraLectura(segundos: Int) async -> CLLocation? {
        await withTaskGroup(of: CLLocation?.self) { grupo in
            grupo.addTask {
                // La sesión pide el permiso "mientras se usa la app" si todavía no se ha preguntado.
                let sesion = CLServiceSession(authorization: .whenInUse)
                defer { sesion.invalidate() }
                do {
                    for try await lectura in CLLocationUpdate.liveUpdates() {
                        if let lugar = lectura.location { return lugar }
                        if lectura.authorizationDenied || lectura.authorizationDeniedGlobally
                            || lectura.authorizationRestricted { return nil }
                    }
                } catch {}
                return nil
            }
            grupo.addTask {
                try? await Task.sleep(for: .seconds(segundos))
                return nil
            }
            let primera = await grupo.next() ?? nil
            grupo.cancelAll()
            return primera
        }
    }

    private static func direccion(de lugar: CLLocation) async -> (completa: String, corta: String)? {
        guard let peticion = MKReverseGeocodingRequest(location: lugar) else { return nil }
        peticion.preferredLocale = Locale(identifier: "es_MX")
        guard let direccion = try? await peticion.mapItems.first?.address else { return nil }
        return (direccion.fullAddress, direccion.shortAddress ?? direccion.fullAddress)
    }
}
