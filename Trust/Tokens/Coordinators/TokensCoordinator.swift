// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

protocol TokensCoordinatorDelegate: class {
    func didPress(for type: PaymentFlow, in coordinator: TokensCoordinator)
    func didPress(on token: NonFungibleToken, in coordinator: TokensCoordinator)
}

class TokensCoordinator: Coordinator {

    let navigationController: UINavigationController
    let session: WalletSession
    let keystore: Keystore
    var coordinators: [Coordinator] = []
    let storage: TokensDataStore

    lazy var tokensViewController: TokensViewController = {
        let controller = TokensViewController(
            account: session.account,
            dataStore: storage
        )
        controller.delegate = self
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(edit))
        controller.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addToken))
        return controller
    }()
    weak var delegate: TokensCoordinatorDelegate?

    lazy var rootViewController: TokensViewController = {
        return self.tokensViewController
    }()

    init(
        navigationController: UINavigationController = NavigationController(),
        session: WalletSession,
        keystore: Keystore,
        tokensStorage: TokensDataStore
    ) {
        self.navigationController = navigationController
        self.navigationController.modalPresentationStyle = .formSheet
        self.session = session
        self.keystore = keystore
        self.storage = tokensStorage
    }

    func start() {
        showTokens()
    }

    func showTokens() {
        navigationController.viewControllers = [rootViewController]
    }

    func newTokenViewController() -> NewTokenViewController {
        let controller = NewTokenViewController()
        controller.delegate = self
        return controller
    }

    @objc func addToken() {
        let controller = newTokenViewController()
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismiss))
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .formSheet
        navigationController.present(nav, animated: true, completion: nil)
    }

    @objc func dismiss() {
        navigationController.dismiss(animated: true, completion: nil)
    }

    @objc func edit() {
        let controller = EditTokensViewController(
            session: session,
            storage: storage
        )
        navigationController.pushViewController(controller, animated: true)
    }
}

extension TokensCoordinator: TokensViewControllerDelegate {
    func didSelect(token: TokenItem, in viewController: UIViewController) {

        switch token {
        case .token(let token):
            let type: TokenType = {
                return TokensDataStore.etherToken(for: session.config) == token ? .ether : .token
            }()

            switch type {
            case .ether:
                delegate?.didPress(for: .send(type: .ether(destination: .none)), in: self)
            case .token:
                delegate?.didPress(for: .send(type: .token(token)), in: self)
            }
        case .nonFungibleTokens(let token):
            delegate?.didPress(on: token, in: self)
        }
    }

    func didDelete(token: TokenItem, in viewController: UIViewController) {
        switch token {
        case .token(let token):
            storage.delete(tokens: [token])
            tokensViewController.fetch()
        case .nonFungibleTokens: break
        }
    }

    func didPressAddToken(in viewController: UIViewController) {
        addToken()
    }
}

extension TokensCoordinator: NewTokenViewControllerDelegate {
    func didAddToken(token: ERC20Token, in viewController: NewTokenViewController) {
        storage.addCustom(token: token)
        tokensViewController.fetch()
        dismiss()
    }
}
