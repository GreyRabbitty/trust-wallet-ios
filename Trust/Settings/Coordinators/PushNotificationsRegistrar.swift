// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UserNotifications
import UIKit
import Moya
import TrustCore

class PushNotificationsRegistrar {

    private let trustProvider = TrustProviderFactory.makeProvider()
    let config = Config()

    var isRegisteredForRemoteNotifications: Bool {
        return UIApplication.shared.isRegisteredForRemoteNotifications
    }

    func reRegister() {
        guard isRegisteredForRemoteNotifications else { return }
        register()
    }

    func register() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .alert, .sound]) { _, _  in }
        UIApplication.shared.registerForRemoteNotifications()
    }

    func unregister() {
        let device = PushDevice(
            deviceID: UIDevice.current.identifierForVendor!.uuidString,
            token: "",
            wallets: [],
            preferences: NotificationsViewController.getPreferences()
        )

        trustProvider.request(.unregister(device: device)) { _ in }
        UIApplication.shared.unregisterForRemoteNotifications()
    }

    func didRegister(with deviceToken: Data, addresses: [Address]) {
        let token = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }.joined()

        let device = PushDevice(
            deviceID: UIDevice.current.identifierForVendor!.uuidString,
            token: token,
            wallets: addresses.map { $0.description },
            preferences: NotificationsViewController.getPreferences()
        )

        trustProvider.request(.register(device: device)) { _ in }
    }
}
