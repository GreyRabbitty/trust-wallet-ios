// Copyright SIX DAY LLC. All rights reserved.

import UIKit
import Eureka
import TrustCore
import QRCodeReaderViewController

protocol ImportWalletViewControllerDelegate: class {
    func didImportAccount(account: Wallet, in viewController: ImportWalletViewController)
}

class ImportWalletViewController: FormViewController {

    let keystore: Keystore
    private let viewModel = ImportWalletViewModel()

    struct Values {
        static let segment = "segment"
        static let keystore = "keystore"
        static let privateKey = "privateKey"
        static let password = "password"
        static let watch = "watch"
        static let mnemonic = "mnemonic"
    }

    lazy var pargraphStyle: NSMutableParagraphStyle = {
        let style = NSMutableParagraphStyle()
        style.lineHeightMultiple = 1.25
        style.alignment = .natural
        return style
    }()

    var segmentRow: SegmentedRow<String>? {
        return form.rowBy(tag: Values.segment)
    }

    var keystoreRow: TextAreaRow? {
        return form.rowBy(tag: Values.keystore)
    }

    var mnemonicRow: TextAreaRow? {
        return form.rowBy(tag: Values.mnemonic)
    }

    var privateKeyRow: TextAreaRow? {
        return form.rowBy(tag: Values.privateKey)
    }

    var passwordRow: TextFloatLabelRow? {
        return form.rowBy(tag: Values.password)
    }

    var watchRow: TextFloatLabelRow? {
        return form.rowBy(tag: Values.watch)
    }

    weak var delegate: ImportWalletViewControllerDelegate?

    init(
        keystore: Keystore
    ) {
        self.keystore = keystore
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = viewModel.title
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: R.image.import_options(), style: .done, target: self, action: #selector(importOptions)),
            UIBarButtonItem(image: R.image.qr_code_icon(), style: .done, target: self, action: #selector(openReader)),
        ]

        if UserDefaults.standard.bool(forKey: "FASTLANE_SNAPSHOT") {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.demo()
            }
        }

        let recipientRightView = FieldAppereance.addressFieldRightView(
            pasteAction: { [unowned self] in self.pasteAddressAction() },
            qrAction: { [unowned self] in self.openReader() }
        )

        form
            +++ Section {
                var header = HeaderFooterView<InfoHeaderView>(.class)
                header.height = { 90 }
                header.onSetupView = { (view, section) -> Void in
                    view.label.attributedText = NSAttributedString(string: "Importing wallet as easy as creating", attributes: [
                        NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular),
                        NSAttributedStringKey.foregroundColor: UIColor(hex: "6e6e72"),
                        NSAttributedStringKey.paragraphStyle: self.pargraphStyle,
                        ])
                    view.logoImageView.image = R.image.create_wallet_import()
                }
                $0.header = header
            }

            <<< SegmentedRow<String>(Values.segment) {
                $0.options = [
                    ImportSelectionType.keystore.title,
                    ImportSelectionType.privateKey.title,
                    ImportSelectionType.mnemonic.title,
                    ImportSelectionType.watch.title,
                ]
                $0.value = ImportSelectionType.keystore.title
            }

            <<< AppFormAppearance.textArea(tag: Values.mnemonic) {
                $0.placeholder = NSLocalizedString("import.wallet.mnemonic.placeholder", value: "Words separated by a space. (Usually contains 12 words)", comment: "")
                $0.textAreaHeight = .fixed(cellHeight: 140)
                $0.add(rule: RuleRequired())
                $0.cell.textView?.autocapitalizationType = .none

                $0.hidden = Eureka.Condition.function([Values.segment], { _ in
                    return self.segmentRow?.value != ImportSelectionType.mnemonic.title
                })
            }

            <<< AppFormAppearance.textArea(tag: Values.keystore) {
                $0.placeholder = NSLocalizedString("Keystore JSON", value: "Keystore JSON", comment: "")
                $0.textAreaHeight = .fixed(cellHeight: 140)
                $0.add(rule: RuleRequired())

                $0.hidden = Eureka.Condition.function([Values.segment], { _ in
                    return self.segmentRow?.value != ImportSelectionType.keystore.title
                })
            }

            <<< AppFormAppearance.textArea(tag: Values.privateKey) {
                $0.placeholder = NSLocalizedString("Private Key", value: "Private Key", comment: "")
                $0.textAreaHeight = .fixed(cellHeight: 140)
                $0.add(rule: RuleRequired())
                $0.add(rule: PrivateKeyRule())
                $0.hidden = Eureka.Condition.function([Values.segment], { _ in
                    return self.segmentRow?.value != ImportSelectionType.privateKey.title
                })
            }

            <<< AppFormAppearance.textFieldFloat(tag: Values.watch) {
                $0.add(rule: RuleRequired())
                $0.add(rule: EthereumAddressRule())
                $0.hidden = Eureka.Condition.function([Values.segment], { _ in
                 return self.segmentRow?.value != ImportSelectionType.watch.title
            })
            }.cellUpdate { cell, _ in
                cell.textField.placeholder = self.viewModel.watchAddressPlaceholder
                cell.textField.rightView = recipientRightView
                cell.textField.rightViewMode = .always
            }

            <<< AppFormAppearance.textFieldFloat(tag: Values.password) {
                $0.validationOptions = .validatesOnDemand
                $0.hidden = Eureka.Condition.function([Values.segment], { _ in
                    return self.segmentRow?.value != ImportSelectionType.keystore.title
                })
            }.cellUpdate { cell, _ in
                cell.textField.isSecureTextEntry = true
                cell.textField.textAlignment = .left
                cell.textField.placeholder = NSLocalizedString("Password", value: "Password", comment: "")
            }

            +++ Section("")

            <<< ButtonRow(NSLocalizedString("importWallet.import.button.title", value: "Import", comment: "")) {
                $0.title = $0.tag
            }.onCellSelection { [unowned self] _, _ in
                self.importWallet()
            }
    }

    func didImport(account: Wallet) {
        delegate?.didImportAccount(account: account, in: self)
    }

    func importWallet() {
        let validatedError = keystoreRow?.section?.form?.validate()
        guard let errors = validatedError, errors.isEmpty else { return }

        let keystoreInput = keystoreRow?.value?.trimmed ?? ""
        let privateKeyInput = privateKeyRow?.value?.trimmed ?? ""
        let password = passwordRow?.value ?? ""
        let watchInput = watchRow?.value?.trimmed ?? ""
        let mnemonicInput = mnemonicRow?.value?.trimmed ?? ""
        let words = mnemonicInput.components(separatedBy: " ").map { $0.trimmed.lowercased() }

        displayLoading(text: NSLocalizedString("importWallet.importingIndicator.label.title", value: "Importing wallet...", comment: ""), animated: false)

        let type = ImportSelectionType(title: segmentRow?.value)
        let importType: ImportType = {
            switch type {
            case .keystore:
                return .keystore(string: keystoreInput, password: password)
            case .privateKey:
                return .privateKey(privateKey: privateKeyInput)
            case .mnemonic:
                return .mnemonic(words: words, password: password)
            case .watch:
                let address = Address(string: watchInput)! // Address validated by form view.
                return .watch(address: address)
            }
        }()

        keystore.importWallet(type: importType) { result in
            self.hideLoading(animated: false)
            switch result {
            case .success(let account):
                self.didImport(account: account)
            case .failure(let error):
                self.displayError(error: error)
            }
        }
    }

    @objc func demo() {
        //Used for taking screenshots to the App Store by snapshot
        let demoWallet = Wallet(type: .address(Address(string: "0xD663bE6b87A992C5245F054D32C7f5e99f5aCc47")!))
        delegate?.didImportAccount(account: demoWallet, in: self)
    }

    @objc func importOptions(sender: UIBarButtonItem) {
        let alertController = UIAlertController(
            title: NSLocalizedString("importWallet.import.alertSheet.title", value: "Import Wallet Options", comment: ""),
            message: .none,
            preferredStyle: .actionSheet
        )
        alertController.popoverPresentationController?.barButtonItem = sender
        alertController.addAction(UIAlertAction(
            title: NSLocalizedString("importWallet.import.alertSheet.option.title", value: "iCloud/Dropbox/Google Drive", comment: ""),
            style: .default
        ) { _ in
            self.showDocumentPicker()
        })
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", value: "Cancel", comment: ""), style: .cancel) { _ in })
        present(alertController, animated: true)
    }

    func showDocumentPicker() {
        let types = ["public.text", "public.content", "public.item", "public.data"]
        let controller = TrustDocumentPickerViewController(documentTypes: types, in: .import)
        controller.delegate = self
        controller.modalPresentationStyle = .formSheet
        present(controller, animated: true, completion: nil)
    }

    @objc func openReader() {
        let controller = QRCodeReaderViewController()
        controller.delegate = self
        present(controller, animated: true, completion: nil)
    }

    func setValueForCurrentField(string: String) {
        let type = ImportSelectionType(title: segmentRow?.value)
        switch type {
        case .keystore:
            keystoreRow?.value = string
            keystoreRow?.reload()
        case .privateKey:
            privateKeyRow?.value = string
            privateKeyRow?.reload()
        case .watch:
            guard let result = QRURLParser.from(string: string) else { return }
            watchRow?.value = result.address
            watchRow?.reload()
        case .mnemonic:
            mnemonicRow?.value = string
            mnemonicRow?.reload()
        }
    }

    @objc func pasteAddressAction() {
        let value = UIPasteboard.general.string?.trimmed
        watchRow?.value = value
        watchRow?.reload()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

extension ImportWalletViewController: QRCodeReaderDelegate {
    func readerDidCancel(_ reader: QRCodeReaderViewController!) {
        reader.stopScanning()
        reader.dismiss(animated: true, completion: nil)
    }
    func reader(_ reader: QRCodeReaderViewController!, didScanResult result: String!) {
        reader.stopScanning()
        setValueForCurrentField(string: result)
        reader.dismiss(animated: true)
    }
}
