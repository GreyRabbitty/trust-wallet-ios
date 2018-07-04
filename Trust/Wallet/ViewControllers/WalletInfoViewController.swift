// Copyright SIX DAY LLC. All rights reserved.

import UIKit
import Eureka
import TrustKeystore

protocol WalletInfoViewControllerDelegate: class {
    func didPress(item: WalletInfoType, in controller: WalletInfoViewController)
    func didPressSave(wallet: WalletInfo, field: WalletInfoField, in controller: WalletInfoViewController)
}

struct WalletInfoField {
    let name: String
}

class WalletInfoViewController: FormViewController {

    lazy var viewModel: WalletInfoViewModel = {
        return WalletInfoViewModel(wallet: wallet)
    }()
    var segmentRow: TextFloatLabelRow? {
        return form.rowBy(tag: Values.name)
    }
    let wallet: WalletInfo
    let storage: WalletStorage

    weak var delegate: WalletInfoViewControllerDelegate?

    private struct Values {
        static let name = "name"
    }

    lazy var saveBarButtonItem: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
    }()

    init(
        wallet: WalletInfo,
        storage: WalletStorage
    ) {
        self.wallet = wallet
        self.storage = storage
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = viewModel.title
        navigationItem.rightBarButtonItem = saveBarButtonItem

        let types = viewModel.types
        let section = Section(footer: viewModel.wallet.address.description)
        for type in types {
            section.append(link(item: type))
        }

        form +++ Section()

        <<< AppFormAppearance.textFieldFloat(tag: Values.name) {
            $0.add(rule: RuleRequired())
            $0.value = self.wallet.info.name
        }.cellUpdate { [weak self] cell, _ in
            cell.textField.placeholder = self?.viewModel.nameTitle
            cell.textField.rightViewMode = .always
        }

        +++ section
    }

    private func link(
        item: WalletInfoType
    ) -> ButtonRowRow {
        let button = ButtonRowRow(item.title) {
            $0.title = item.title
            $0.value = item
        }.onCellSelection { [weak self] (_, row) in
            guard let `self` = self, let item = row.value else { return }
            self.delegate?.didPress(item: item, in: self)
        }.cellSetup { cell, _ in
            cell.imageView?.image = item.image
        }.cellUpdate { cell, _ in
            cell.textLabel?.textAlignment = .left
            cell.textLabel?.textColor = .black
            cell.accessoryType = .disclosureIndicator
        }
        return button
    }

    @objc func save() {
        let name = segmentRow?.value ?? ""
        let field = WalletInfoField(name: name)
        delegate?.didPressSave(wallet: wallet, field: field, in: self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

typealias ButtonRowRow = ButtonRowOf<WalletInfoType>
