// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import APIKit
import JSONRPCKit
import Result
import BigInt
import RealmSwift

protocol BalanceCoordinatorDelegate: class {
    func didUpdate(viewModel: BalanceViewModel)
}

class BalanceCoordinator {
    let account: Wallet
    let storage: TokensDataStore
    let config: Config
    var balance: Balance?
    var currencyRate: CurrencyRate?
    weak var delegate: BalanceCoordinatorDelegate?
    var ethTokenObservation: NotificationToken?
    var viewModel: BalanceViewModel {
        return BalanceViewModel(
            balance: balance,
            rate: currencyRate
        )
    }
    init(
        account: Wallet,
        config: Config,
        storage: TokensDataStore
    ) {
        self.account = account
        self.config = config
        self.storage = storage
        balanceObservation()
    }
    func refresh() {
        balanceObservation()
    }
    private func balanceObservation() {
        guard let token = storage.enabledObject.first(where: { $0.name == config.server.name }) else {
            return
        }
        updateBalance(for: token, with: nil)
        ethTokenObservation = token.observe {[weak self] change in
            switch change {
            case .change:
                self?.updateBalance(for: token, with: BigInt(token.value))
            case .error, .deleted:
                break
            }
        }
    }
    private func update() {
        delegate?.didUpdate(viewModel: viewModel)
    }
    private func updateBalance(for token: TokenObject, with value: BigInt?) {
        self.balance = Balance(value: value ?? token.valueBigInt)
        self.currencyRate = CurrencyRate(
            rates: storage.tickers().map { Rate(code: $0.symbol, price: Double($0.price) ?? 0, contract: $0.contract) }
        )
        self.update()
    }

    deinit {
        ethTokenObservation?.invalidate()
        ethTokenObservation = nil
    }
}
