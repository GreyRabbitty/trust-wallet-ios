// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

class AppCoordinator: NSObject, Coordinator {

    let navigationController: UINavigationController

    lazy var welcomeViewController: WelcomeViewController = {
        let controller = WelcomeViewController()
        controller.delegate = self
        return controller
    }()

    let touchRegistrar = TouchRegistrar()
    let pushNotificationRegistrar = PushNotificationsRegistrar()

    private var keystore: Keystore

    var coordinators: [Coordinator] = []

    init(
        window: UIWindow,
        keystore: Keystore = EtherKeystore(),
        navigationController: UINavigationController = NavigationController()
    ) {
        self.keystore = keystore
        self.navigationController = navigationController
        super.init()
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }

    func start() {
        performMigration()
        inializers()
        handleNotifications()

        resetToWelcomeScreen()

        if keystore.hasAccounts {
            showTransactions(for: keystore.recentlyUsedAccount ?? keystore.accounts.first!)
        }
        pushNotificationRegistrar.reRegister()
    }

    func showTransactions(for account: Account) {
        let coordinator = InCoordinator(
            navigationController: navigationController,
            account: account,
            keystore: keystore
        )
        coordinator.delegate = self
        coordinator.start()
        addCoordinator(coordinator)
    }

    func performMigration() {
        MigrationInitializer().perform()
        LokaliseInitializer().perform()
    }

    func inializers() {
        touchRegistrar.register()
    }

    func handleNotifications() {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    func showCreateWallet() {
        let coordinator = WalletCoordinator(navigationController: self.navigationController)
        coordinator.delegate = self
        coordinator.start(.createInstantWallet)
        addCoordinator(coordinator)
    }

    func presentImportWallet() {
        let coordinator = WalletCoordinator()
        coordinator.delegate = self
        coordinator.start(.importWallet)
        navigationController.present(coordinator.navigationController, animated: true, completion: nil)
        addCoordinator(coordinator)
    }

    func resetToWelcomeScreen() {
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.viewControllers = [welcomeViewController]
    }

    @objc func reset() {
        touchRegistrar.unregister()
        pushNotificationRegistrar.unregister()
        coordinators.removeAll()
        navigationController.dismiss(animated: true, completion: nil)
        resetToWelcomeScreen()
    }

    func didRegisterForRemoteNotificationsWithDeviceToken(deviceToken: Data) {
        pushNotificationRegistrar.didRegister(
            with: deviceToken,
            addresses: keystore.accounts.map { $0.address }
        )
    }
}

extension AppCoordinator: WelcomeViewControllerDelegate {
    func didPressCreateWallet(in viewController: WelcomeViewController) {
        showCreateWallet()
    }

    func didPressImportWallet(in viewController: WelcomeViewController) {
        presentImportWallet()
    }
}

extension AppCoordinator: WalletCoordinatorDelegate {
    func didFinish(with account: Account, in coordinator: WalletCoordinator) {
        coordinator.navigationController.dismiss(animated: true, completion: nil)
        showTransactions(for: account)
        removeCoordinator(coordinator)
    }

    func didFail(with error: Error, in coordinator: WalletCoordinator) {
        coordinator.navigationController.dismiss(animated: true, completion: nil)
        removeCoordinator(coordinator)
    }

    func didCancel(in coordinator: WalletCoordinator) {
        coordinator.navigationController.dismiss(animated: true, completion: nil)
        removeCoordinator(coordinator)
    }
}

extension AppCoordinator: InCoordinatorDelegate {
    func didCancel(in coordinator: InCoordinator) {
        removeCoordinator(coordinator)
        pushNotificationRegistrar.reRegister()
        reset()
    }

    func didUpdateAccounts(in coordinator: InCoordinator) {
        pushNotificationRegistrar.reRegister()
    }
}
