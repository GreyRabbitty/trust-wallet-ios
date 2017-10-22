// Copyright SIX DAY LLC. All rights reserved.

import UIKit

protocol AccountsViewControllerDelegate: class {
    func didSelectAccount(account: Account, in viewController: AccountsViewController)
    func didDeleteAccount(account: Account, in viewController: AccountsViewController)
}

class AccountsViewController: UITableViewController {

    weak var delegate: AccountsViewControllerDelegate?
    var allowsAccountDeletion: Bool = false

    var headerTitle: String?

    var viewModel: AccountsViewModel {
        return AccountsViewModel(
            accounts: accounts
        )
    }

    var hasAccounts: Bool {
        return !accounts.isEmpty
    }

    var accounts: [Account] = [] {
        didSet {
            tableView.reloadData()
            configure(viewModel: viewModel)
        }
    }

    let current = EtherKeystore.current

    private lazy var keystore = EtherKeystore()

    init() {
        super.init(style: .grouped)
        fetch()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        fetch()
    }

    func fetch() {
        accounts = keystore.accounts.map {
            Account(address: Address(address: $0.address.address))
        }
    }

    func configure(viewModel: AccountsViewModel) {
        title = headerTitle ?? viewModel.title
    }

    func account(for indexPath: IndexPath) -> Account {
        return viewModel.accounts[indexPath.row]
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.accounts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let account = self.account(for: indexPath)
        let cell = AccountViewCell(style: .default, reuseIdentifier: AccountViewCell.identifier)
        cell.configure(viewModel: AccountViewModel(account: account, current: current))
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return allowsAccountDeletion && (current != viewModel.accounts[indexPath.row] || viewModel.accounts.count == 1)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            let account = self.account(for: indexPath)
            confirmDelete(account: account)
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let account = self.account(for: indexPath)
        delegate?.didSelectAccount(account: account, in: self)
    }

    func confirmDelete(account: Account) {
        confirm(title: "Are you sure you would like to delete this wallet?", message: "Make sure you have backup of your wallet") { result in
            switch result {
            case .success:
                self.delete(account: account)
            case .failure: break
            }
        }
    }

    func delete(account: Account) {
        let result = self.keystore.delete(account: account)
        switch result {
        case .success:
            self.fetch()
            self.delegate?.didDeleteAccount(account: account, in: self)
        case .failure(let error):
            self.displayError(error: error)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
