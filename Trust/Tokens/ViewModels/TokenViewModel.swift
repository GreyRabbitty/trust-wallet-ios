// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import BigInt
import RealmSwift
import TrustCore

final class TokenViewModel {

    private let shortFormatter = EtherNumberFormatter.short
    private let config: Config
    private let store: TokensDataStore
    private let session: WalletSession
    private var tokensNetwork: NetworkProtocol
    private let transactionsStore: TransactionsStorage
    private var tokenTransactions: Results<Transaction>?
    private var tokenTransactionSections: [TransactionSection] = []
    private var notificationToken: NotificationToken?
    private var transactionToken: NotificationToken?

    let token: TokenObject

    var title: String {
        return token.displayName
    }

    var imageURL: URL? {
        return token.imageURL
    }

    var imagePlaceholder: UIImage? {
        return R.image.ethereum_logo_256()
    }

    private var symbol: String {
        return token.symbol
    }

    var amountFont: UIFont {
        return UIFont.systemFont(ofSize: 18, weight: .medium)
    }

    let titleFormmater: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d yyyy"
        return formatter
    }()

    let backgroundColor: UIColor = {
        return .white
    }()

    var amount: String {
        return String(
            format: "%@ %@",
            shortFormatter.string(from: BigInt(token.value) ?? BigInt(), decimals: token.decimals),
            symbol
        )
    }

    var numberOfSections: Int {
        return tokenTransactionSections.count
    }

    init(
        token: TokenObject,
        config: Config = Config(),
        store: TokensDataStore,
        transactionsStore: TransactionsStorage,
        tokensNetwork: NetworkProtocol,
        session: WalletSession
    ) {
        self.token = token
        self.transactionsStore =  transactionsStore
        self.config = config
        self.store = store
        self.tokensNetwork = tokensNetwork
        self.session = session
        prepareDataSource(for: token)
    }

    var ticker: CoinTicker? {
        return store.coinTicker(for: token)
    }

    // Market Price

    var marketPrice: String? {
        return TokensLayout.cell.marketPrice(for: ticker)
    }

    var marketPriceFont: UIFont {
        return UIFont.systemFont(ofSize: 14, weight: .regular)
    }

    var marketPriceTextColor: UIColor {
        return TokensLayout.cell.fiatAmountTextColor
    }

    var totalFiatAmount: String? {
        return TokensLayout.cell.totalFiatAmount(for: ticker, token: token)
    }

    var fiatAmountTextColor: UIColor {
        return TokensLayout.cell.fiatAmountTextColor
    }

    var fiatAmountFont: UIFont {
        return UIFont.systemFont(ofSize: 14, weight: .regular)
    }

    var currencyAmount: String? {
        return TokensLayout.cell.currencyAmount(for: ticker, token: token)
    }

    var amountTextColor: UIColor {
        return TokensLayout.cell.amountTextColor
    }

    var currencyAmountTextColor: UIColor {
        return TokensLayout.cell.currencyAmountTextColor
    }

    var percentChangeColor: UIColor {
        return TokensLayout.cell.percentChangeColor(for: ticker)
    }

    var percentChangeFont: UIFont {
        return UIFont.systemFont(ofSize: 12, weight: .light)
    }

    var percentChange: String? {
        guard let _ = currencyAmount else {
            return .none
        }
        return TokensLayout.cell.percentChange(for: ticker)
    }

    var currencyAmountFont: UIFont {
        return UIFont.systemFont(ofSize: 13, weight: .regular)
    }

    func fetch() {
        updateTokenBalance()
        fetchTransactions()
    }

    func tokenObservation(with completion: @escaping (() -> Void)) {
        notificationToken = token.observe { change in
            switch change {
            case .change, .deleted, .error:
                completion()
            }
        }
    }

    func transactionObservation(with completion: @escaping (() -> Void)) {
        transactionToken = tokenTransactions?.observe { [weak self] _ in
            self?.updateSections()
            completion()
        }
    }

    func numberOfItems(for section: Int) -> Int {
        return tokenTransactionSections[section].items.count
    }

    func item(for row: Int, section: Int) -> Transaction {
        return tokenTransactionSections[section].items[row]
    }

    func convert(from title: String) -> Date? {
        return titleFormmater.date(from: title)
    }

    func titleForHeader(in section: Int) -> String {
        let stringDate = tokenTransactionSections[section].title
        guard let date = convert(from: stringDate) else {
            return stringDate
        }

        if NSCalendar.current.isDateInToday(date) {
            return R.string.localizable.today()
        }
        if NSCalendar.current.isDateInYesterday(date) {
            return R.string.localizable.yesterday()
        }
        return stringDate
    }

    func cellViewModel(for indexPath: IndexPath) -> TransactionCellViewModel {
        let server = RPCServer(chainID: 1)!
        return TransactionCellViewModel(transaction: tokenTransactionSections[indexPath.section].items[indexPath.row], config: config, chainState: ChainState(server: server), currentWallet: session.account, server: server)
        //TODO: Refactor
    }

    func hasContent() -> Bool {
        return !tokenTransactionSections.isEmpty
    }

    private func updateTokenBalance() {
        let provider = TokenViewModel.balance(for: token, wallet: session.account)
        provider.balance().done { [weak self] balance in
            guard let token = self?.token else {
                return
            }
            self?.store.update(balances: [provider.addressUpdate: balance])
        }
    }

    static func balance(for token: TokenObject, wallet: WalletInfo) -> BalanceNetworkProvider {
        let networkBalance: BalanceNetworkProvider = {
            if token.isCoin {
                let acc = wallet.accounts.filter { $0.coin == token.coin }.first!
                let server = RPCServer(chainID: token.chainID)!
                return CoinNetworkProvider(
                    server: server,
                    address: EthereumAddress(string: acc.address.description)!,
                    addressUpdate: token.address
                )
            } else {
                let acc = wallet.accounts.filter { $0.coin == token.coin }.first!
                return TokenNetworkProvider(
                    server: RPCServer.main,
                    address: EthereumAddress(string: acc.address.description)!,
                    contract: token.address,
                    addressUpdate: token.address
                )
            }
        }()
        return networkBalance
    }

    private func fetchTransactions() {
        let contract: String? = {
            guard let _ = token.coin else {
                return .none
            }
            return token.contract
        }()

        tokensNetwork.transactions(for: session.account.address, startBlock: 1, page: 0, contract: contract) { result in
            guard let transactions = result.0 else { return }
            self.transactionsStore.add(transactions)
        }
    }

    private func prepareDataSource(for token: TokenObject) {
        if token.coin != nil {
            tokenTransactions = transactionsStore.realm.objects(Transaction.self).filter(NSPredicate(format: "localizedOperations.@count == 0")).sorted(byKeyPath: "date", ascending: false)
        } else {
            tokenTransactions = transactionsStore.realm.objects(Transaction.self).filter(NSPredicate(format: "%K ==[cd] %@", "to", token.contract)).sorted(byKeyPath: "date", ascending: false)
        }
        updateSections()
    }

    private func updateSections() {
        guard let tokens = tokenTransactions else { return }
        tokenTransactionSections = transactionsStore.mappedSections(for: Array(tokens))
    }

    func invalidateObservers() {
        notificationToken?.invalidate()
        notificationToken = nil
        transactionToken?.invalidate()
        transactionToken = nil
    }
}
