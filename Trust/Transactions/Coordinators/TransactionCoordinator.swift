// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import Result

protocol TransactionCoordinatorDelegate: class {
    func didCancel(in coordinator: TransactionCoordinator)
    func didRestart(with account: Account, in coordinator: TransactionCoordinator)
    func didPressAccounts(in coordinator: TransactionCoordinator)
}

class TransactionCoordinator: Coordinator {

    private let keystore: Keystore
    private let storage: TransactionsStorage
    lazy var rootViewController: TransactionsViewController = {
        let controller = self.makeTransactionsController(with: self.session.account)
        return controller
    }()

    lazy var dataCoordinator: TransactionDataCoordinator = {
        let coordinator = TransactionDataCoordinator(
            account: self.session.account,
            storage: self.storage
        )
        return coordinator
    }()

    weak var delegate: TransactionCoordinatorDelegate?

    lazy var settingsCoordinator: SettingsCoordinator = {
        return SettingsCoordinator(navigationController: self.navigationController)
    }()

    let session: WalletSession
    let navigationController: UINavigationController
    var coordinators: [Coordinator] = []

    init(
        session: WalletSession,
        rootNavigationController: UINavigationController,
        storage: TransactionsStorage
    ) {
        self.session = session
        self.keystore = EtherKeystore()
        self.navigationController = rootNavigationController
        self.storage = storage

        NotificationCenter.default.addObserver(self, selector: #selector(didEnterForeground), name: .UIApplicationWillEnterForeground, object: nil)
    }

    private func makeTransactionsController(with account: Account) -> TransactionsViewController {
        let controller = TransactionsViewController(
            account: account,
            dataCoordinator: dataCoordinator,
            session: session
        )
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(image: R.image.settings_icon(), landscapeImagePhone: R.image.settings_icon(), style: UIBarButtonItemStyle.done, target: self, action: #selector(showSettings))
        controller.navigationItem.rightBarButtonItem = UIBarButtonItem(image: R.image.accountsSwitch(), landscapeImagePhone: R.image.accountsSwitch(), style: UIBarButtonItemStyle.done, target: self, action: #selector(showAccounts))
        controller.delegate = self
        return controller
    }

    @objc func showAccounts() {
        delegate?.didPressAccounts(in: self)
    }

    @objc func showSettings() {
        settingsCoordinator.start()
        settingsCoordinator.delegate = self
    }

    func showTokens(for account: Account) {
        let controller = TokensViewController(account: account)
        if UIDevice.current.userInterfaceIdiom == .pad {
            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .formSheet
            controller.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismiss))
            navigationController.present(nav, animated: true, completion: nil)
        } else {
            navigationController.pushViewController(controller, animated: true)
        }
    }

    func showTransaction(_ transaction: Transaction) {
        let controller = TransactionViewController(
            transaction: transaction
        )
        if UIDevice.current.userInterfaceIdiom == .pad {
            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .formSheet
            controller.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismiss))
            navigationController.present(nav, animated: true, completion: nil)
        } else {
            navigationController.pushViewController(controller, animated: true)
        }
    }

    func showPaymentFlow(for type: PaymentFlow, session: WalletSession) {
        let coordinator = PaymentCoordinator(
            flow: type,
            session: session
        )
        coordinator.delegate = self
        navigationController.present(coordinator.navigationController, animated: true, completion: nil)
        addCoordinator(coordinator)
    }

    @objc func didEnterForeground() {
        rootViewController.fetch()
    }

    @objc func dismiss() {
        navigationController.dismiss(animated: true, completion: nil)
    }

    func stop() {
        dataCoordinator.stop()
        session.stop()
    }

    func restart(for account: Account) {
        delegate?.didRestart(with: account, in: self)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension TransactionCoordinator: SettingsCoordinatorDelegate {
    func didUpdate(action: SettingsAction, in coordinator: SettingsCoordinator) {
        switch action {
        case .RPCServer:
            restart(for: session.account)
        case .exportPrivateKey, .pushNotifications:
            break
        case .donate(let address):
            coordinator.navigationController.dismiss(animated: true) {
                self.showPaymentFlow(for: .send(destination: address), session: self.session)
            }
        }
    }

    func didCancel(in coordinator: SettingsCoordinator) {
        coordinator.navigationController.dismiss(animated: true, completion: nil)
    }
}

extension TransactionCoordinator: TransactionsViewControllerDelegate {
    func didPressSend(in viewController: TransactionsViewController) {
        showPaymentFlow(for: .send(destination: .none), session: session)
    }

    func didPressRequest(in viewController: TransactionsViewController) {
        showPaymentFlow(for: .request, session: session)
    }

    func didPressTransaction(transaction: Transaction, in viewController: TransactionsViewController) {
        showTransaction(transaction)
    }

    func didPressTokens(in viewController: TransactionsViewController) {
        showTokens(for: session.account)
    }

    func reset() {
        delegate?.didCancel(in: self)
    }
}

extension TransactionCoordinator: PaymentCoordinatorDelegate {
    func didCancel(in coordinator: PaymentCoordinator) {
        coordinator.navigationController.dismiss(animated: true, completion: nil)
        removeCoordinator(coordinator)
    }

    func didCreatePendingTransaction(_ transaction: SentTransaction, in viewController: PaymentCoordinator) {
        dataCoordinator.fetchTransaction(hash: transaction.id)
    }
}
