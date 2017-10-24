// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

protocol BackupCoordinatorDelegate: class {
    func didCancel(coordinator: BackupCoordinator)
    func didFinish(account: Account, in coordinator: BackupCoordinator)
}

class BackupCoordinator: Coordinator {

    let navigationController: UINavigationController
    weak var delegate: BackupCoordinatorDelegate?
    let keystore = EtherKeystore()
    let account: Account
    var coordinators: [Coordinator] = []

    init(
        navigationController: UINavigationController,
        account: Account
    ) {
        self.navigationController = navigationController
        self.account = account
    }

    func start() {
        export(for: account)
    }

    func finish(completed: Bool) {
        if completed {
            delegate?.didFinish(account: account, in: self)
        } else {
            delegate?.didCancel(coordinator: self)
        }
    }

    func presentActivityViewController(for account: Account, password: String, newPassword: String, completion: @escaping (Bool) -> Void) {
        let result = keystore.export(account: account, password: password, newPassword: newPassword)

        switch result {
        case .success(let value):
            let activityViewController = UIActivityViewController(
                activityItems: [value],
                applicationActivities: nil
            )
            activityViewController.completionWithItemsHandler = { result in
                completion(result.1)
            }
            activityViewController.popoverPresentationController?.sourceView = navigationController.view
            navigationController.present(activityViewController, animated: true, completion: nil)
        case .failure(let error):
            navigationController.displayError(error: error)
        }
    }

    func presentShareActivity(for account: Account, password: String, newPassword: String) {
        self.presentActivityViewController(for: account, password: password, newPassword: newPassword) { completed in
            self.finish(completed: completed)
        }
    }

    func export(for account: Account) {
        if let currentPassword = keystore.getPassword(for: account) {
            let verifyController = UIAlertController.askPassword(
                title: NSLocalizedString("export.enterPasswordWallet", value: "Enter password to backup your wallet", comment: "")
            ) { result in
                switch result {
                case .success(let newPassword):
                    self.presentShareActivity(
                        for: account,
                        password: currentPassword,
                        newPassword: newPassword
                    )
                case .failure: break
                }
            }
            navigationController.present(verifyController, animated: true, completion: nil)
        } else {
            //FIXME: remove later. for old version, when password were missing in the keychain
            let verifyController = UIAlertController.askPassword(
                title: NSLocalizedString("export.enterCurrentPasswordWallet", value: "Enter current password to export your wallet", comment: "")
            ) { result in
                switch result {
                case .success(let newPassword):
                    self.presentShareActivity(
                        for: account,
                        password: newPassword,
                        newPassword: newPassword
                    )
                case .failure: break
                }
            }
            navigationController.present(verifyController, animated: true, completion: nil)
        }
    }
}
