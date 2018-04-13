// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import BigInt
import RealmSwift

class TokenViewModel {

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

    var amount: String {
        return String(
            format: "%@ %@",
            shortFormatter.string(from: BigInt(token.value) ?? BigInt(), decimals: token.decimals),
            symbol
        )
    }

    var isBuyActionAvailable: Bool {
        switch config.server {
        case .main, .kovan, .classic, .callisto, .ropsten, .rinkeby, .poa, .sokol, .custom: return false
        }
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
        getTokenBalance()
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

    func titleForHeader(in section: Int) -> String {
        let stringDate = tokenTransactionSections[section].title
        guard let date = TransactionsViewModel.convert(from: stringDate) else {
            return stringDate
        }

        if NSCalendar.current.isDateInToday(date) {
            return NSLocalizedString("Today", value: "Today", comment: "")
        }
        if NSCalendar.current.isDateInYesterday(date) {
            return NSLocalizedString("Yesterday", value: "Yesterday", comment: "")
        }
        return stringDate
    }

    func hederView(for section: Int) -> UIView {
        return SectionHeader(
            fillColor: TransactionsViewModel.headerBackgroundColor,
            borderColor: TransactionsViewModel.headerBorderColor,
            title: titleForHeader(in: section),
            textColor: TransactionsViewModel.headerTitleTextColor,
            textFont: TransactionsViewModel.headerTitleFont
        )
    }

    func cellViewModel(for indexPath: IndexPath) -> TransactionCellViewModel {
        return TransactionCellViewModel(transaction: tokenTransactionSections[indexPath.section].items[indexPath.row], config: config, chainState: session.chainState, currentWallet: session.account)
    }

    func hasContent() -> Bool {
        return !tokenTransactionSections.isEmpty
    }

    private func getTokenBalance() {
        tokensNetwork.tokenBalance(for: token.address) { [weak self] (result) in
            guard let balance = result, let token = self?.token else {
                return
            }
            self?.store.update(balances: [token.address: balance.value])
        }
    }

    private func fetchTransactions() {
        tokensNetwork.transactions(for: session.account.address, startBlock: 1, page: 0, contract: token.contract) { result in
            guard let transactions = result.0 else { return }
            self.transactionsStore.add(transactions)
        }
    }

    private func prepareDataSource(for token: TokenObject) {
        if TokensDataStore.etherToken(for: session.config) == token {
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
