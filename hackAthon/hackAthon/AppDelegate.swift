//
//  AppDelegate.swift
//  hackAthon
//
//  Recibe las respuestas a las notificaciones de Mijo ("Ya me la tomé",
//  "Más tarde", "Sí", "Todavía no"), aunque la app esté cerrada.
//

import UIKit
import UserNotifications

final class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        NotificationService.configurar()
        return true
    }

    /// Con la app abierta, la notificación también se ve y se oye.
    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter,
                                            willPresent notification: UNNotification) async
        -> UNNotificationPresentationOptions {
        [.banner, .list, .sound]
    }

    /// Tocó un botón de la notificación.
    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter,
                                            didReceive response: UNNotificationResponse) async {
        let respuesta = NotificationService.Respuesta(response)
        await NotificationService.atender(respuesta)
    }
}
