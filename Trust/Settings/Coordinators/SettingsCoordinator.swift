// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import TrustKeystore
import UIKit

protocol SettingsCoordinatorDelegate: class {
    func didRestart(with account: Wallet, in coordinator: SettingsCoordinator)
    func didUpdateAccounts(in coordinator: SettingsCoordinator)
    func didCancel(in coordinator: SettingsCoordinator)
}

class SettingsCoordinator: Coordinator {

    let navigationController: UINavigationController
    let keystore: Keystore
    let session: WalletSession
    let storage: TransactionsStorage
    let balanceCoordinator: GetBalanceCoordinator
    weak var delegate: SettingsCoordinatorDelegate?
    let pushNotificationsRegistrar = PushNotificationsRegistrar()
    var coordinators: [Coordinator] = []

    lazy var rootViewController: SettingsViewController = {
        let controller = SettingsViewController(session: session)
        controller.delegate = self
        controller.modalPresentationStyle = .pageSheet
        return controller
    }()

    init(
        navigationController: UINavigationController = NavigationController(),
        keystore: Keystore,
        session: WalletSession,
        storage: TransactionsStorage,
        balanceCoordinator: GetBalanceCoordinator
    ) {
        self.navigationController = navigationController
        self.navigationController.modalPresentationStyle = .formSheet
        self.keystore = keystore
        self.session = session
        self.storage = storage
        self.balanceCoordinator = balanceCoordinator
    }

    func start() {
        navigationController.viewControllers = [rootViewController]
    }

    @objc func showAccounts() {
        let coordinator = AccountsCoordinator(
            navigationController: NavigationController(),
            keystore: keystore,
            balanceCoordinator: balanceCoordinator
        )
        coordinator.delegate = self
        coordinator.start()
        addCoordinator(coordinator)
        navigationController.present(coordinator.navigationController, animated: true, completion: nil)
    }

    func restart(for wallet: Wallet) {
        delegate?.didRestart(with: wallet, in: self)
    }
}

extension SettingsCoordinator: SettingsViewControllerDelegate {
    func didAction(action: SettingsAction, in viewController: SettingsViewController) {
        switch action {
        case .wallets:
            showAccounts()
        case .RPCServer, .currency, .DAppsBrowser:
            restart(for: session.account)
        case .pushNotifications(let change):
            switch change {
            case .state(let isEnabled):
                switch isEnabled {
                case true:
                    pushNotificationsRegistrar.register()
                case false:
                    pushNotificationsRegistrar.unregister()
                }
            case .preferences:
                pushNotificationsRegistrar.register()
            }
        }
    }
}

extension SettingsCoordinator: AccountsCoordinatorDelegate {
    func didAddAccount(account: Wallet, in coordinator: AccountsCoordinator) {
        delegate?.didUpdateAccounts(in: self)
    }

    func didDeleteAccount(account: Wallet, in coordinator: AccountsCoordinator) {
        storage.deleteAll()
        delegate?.didUpdateAccounts(in: self)
        guard !coordinator.accountsViewController.hasWallets else { return }
        coordinator.navigationController.dismiss(animated: true, completion: nil)
        delegate?.didCancel(in: self)
    }

    func didCancel(in coordinator: AccountsCoordinator) {
        coordinator.navigationController.dismiss(animated: true, completion: nil)
        removeCoordinator(coordinator)
    }

    func didSelectAccount(account: Wallet, in coordinator: AccountsCoordinator) {
        coordinator.navigationController.dismiss(animated: true, completion: nil)
        removeCoordinator(coordinator)
        restart(for: account)
    }
}
