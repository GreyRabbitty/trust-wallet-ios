// Copyright SIX DAY LLC. All rights reserved.

import UIKit
import Eureka
import OnePasswordExtension
import BonMot

protocol ImportWalletViewControllerDelegate: class {
    func didImportAccount(account: Account, in viewController: ImportWalletViewController)
}

class ImportWalletViewController: FormViewController {

    private let keystore = EtherKeystore()
    private let viewModel = ImportWalletViewModel()

    struct Values {
        static let keystore = "keystore"
        static let password = "password"
    }

    var keystoreRow: TextAreaRow? {
        return form.rowBy(tag: Values.keystore)
    }

    var passwordRow: TextFloatLabelRow? {
        return form.rowBy(tag: Values.password)
    }

    lazy var onePasswordCoordinator: OnePasswordCoordinator = {
        return OnePasswordCoordinator(keystore: self.keystore)
    }()

    weak var delegate: ImportWalletViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        //Demo purpose
        if isDebug() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Demo", style: .done, target: self, action: #selector(self.demo))
            }
        }

        title = viewModel.title
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: R.image.import_options(), style: .done, target: self, action: #selector(importOptions))

//        if OnePasswordExtension.shared().isAppExtensionAvailable() {
//            self.navigationItem.rightBarButtonItem = UIBarButtonItem(
//                image: R.image.onepasswordButton(),
//                style: .done,
//                target: self,
//                action: #selector(onePasswordImport)
//            )
//        }

        form
            +++ Section {
                var header = HeaderFooterView<InfoHeaderView>(.class)
                header.height = { 90 }
                header.onSetupView = { (view, section) -> Void in
                    view.label.attributedText = "Importing wallet as easy as creating".styled(
                        with:
                        .color(UIColor(hex: "6e6e72")),
                        .font(UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular)),
                        .lineHeightMultiple(1.25)
                    )
                    view.logoImageView.image = R.image.create_wallet_import()
                }
                $0.header = header
            }

            <<< AppFormAppearance.textArea(tag: Values.keystore) {
                $0.placeholder = "Keystore JSON"
                $0.textAreaHeight = .fixed(cellHeight: 140)
                $0.add(rule: RuleRequired())
            }

            <<< AppFormAppearance.textFieldFloat(tag: Values.password) {
                $0.validationOptions = .validatesOnDemand
            }.cellUpdate { cell, _ in
                cell.textField.isSecureTextEntry = true
                cell.textField.textAlignment = .left
                cell.textField.placeholder = "Password"
            }

            +++ Section("")

            <<< ButtonRow("Import") {
                $0.title = $0.tag
            }.onCellSelection { [unowned self] _, _ in
                self.importWallet()
            }
    }

    func didImport(account: Account) {
        delegate?.didImportAccount(account: account, in: self)
    }

    func importWallet() {
        let validatedError = keystoreRow?.section?.form?.validate()
        guard let errors = validatedError, errors.isEmpty else { return }

        let input = keystoreRow?.value ?? ""
        let password = passwordRow?.value ?? ""

        displayLoading(text: NSLocalizedString("importWallet.importingIndicatorTitle", value: "Importing wallet...", comment: ""), animated: false)
        keystore.importKeystore(value: input, password: password) { result in
            switch result {
            case .success(let account):
                self.didImport(account: account)
            case .failure(let error):
                self.displayError(error: error)
            }
            self.hideLoading(animated: false)
        }
    }

    func onePasswordImport() {
        onePasswordCoordinator.importWallet(in: self) { [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success(let password, let keystore):
                self.keystoreRow?.value = keystore
                self.keystoreRow?.reload()
                self.passwordRow?.value = password
                self.passwordRow?.reload()
                self.importWallet()
            case .failure(let error):
                self.displayError(error: error)
            }
        }
    }

    func demo() {
        //Used for taking screenshots to the App Store by snapshot
        let demoAccount = Account(
            address: Address(address: "0xD663bE6b87A992C5245F054D32C7f5e99f5aCc47")
        )
        delegate?.didImportAccount(account: demoAccount, in: self)
    }

    func importOptions() {
        let alertController = UIAlertController(title: "Import Wallet Options", message: .none, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "iCloud/Dropbox/Google Cloud", style: .default) { _ in
            self.showDocumentPicker()
        })
        alertController.addAction(UIAlertAction(title: "Cancel", style: .destructive) { _ in })
        present(alertController, animated: true)
    }

    func showDocumentPicker() {
        let types = ["public.text", "public.content", "public.item", "public.data"]
        let controller = UIDocumentPickerViewController(documentTypes: types, in: .import)
        controller.delegate = self
        present(controller, animated: true, completion: nil)
    }
}

extension ImportWalletViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        if controller.documentPickerMode == UIDocumentPickerMode.import {
            let text = try? String(contentsOfFile: url.path)
            keystoreRow?.value = text
            keystoreRow?.reload()
        }
    }
}
