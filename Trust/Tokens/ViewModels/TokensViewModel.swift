// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

enum TokenItem {
    case token(TokenObject)
    case nonFungibleTokens(NonFungibleToken)
}

struct TokensViewModel {

    let tokens: [TokenObject]
    let tickers: [String: CoinTicker]?
    let nonFungibleTokens: [NonFungibleToken]

    init(
        tokens: [TokenObject],
        nonFungibleTokens: [NonFungibleToken],
        tickers: [String: CoinTicker]?
    ) {
        self.tokens = tokens
        self.nonFungibleTokens = nonFungibleTokens
        self.tickers = tickers
    }

    private var amount: String? {
        var totalAmount: Double = 0
        tokens.forEach { token in
            totalAmount += amount(for: token)
        }
        guard totalAmount != 0 else { return "--" }
        return CurrencyFormatter.formatter.string(from: NSNumber(value: totalAmount))
    }

    private func amount(for token: TokenObject) -> Double {
        guard let tickers = tickers else { return 0 }
        guard !token.valueBigInt.isZero, let tickersSymbol = tickers[token.contract] else { return 0 }
        let tokenValue = CurrencyFormatter.plainFormatter.string(from: token.valueBigInt, decimals: token.decimals).doubleValue
        let price = Double(tickersSymbol.price) ?? 0
        return tokenValue * price
    }

    var headerBalance: String? {
        return amount
    }

    var headerBalanceTextColor: UIColor {
        return Colors.black
    }

    var headerBackgroundColor: UIColor {
        return .white
    }

    var headerBalanceFont: UIFont {
        return UIFont.systemFont(ofSize: 26, weight: .medium)
    }

    var title: String {
        return NSLocalizedString("tokens.navigation.title", value: "Tokens", comment: "")
    }

    var backgroundColor: UIColor {
        return .white
    }

    var hasContent: Bool {
        return !tokens.isEmpty || !nonFungibleTokens.isEmpty
    }

    var numberOfSections: Int {
        return 2
    }

    func numberOfItems(for section: Int) -> Int {
        switch section {
        case 0:
            return tokens.count
        case 1:
            return nonFungibleTokens.count
        default: return 0
        }
    }

    func item(for row: Int, section: Int) -> TokenItem {
        switch section {
        case 0:
            return .token(tokens[row])
        default:
            return .nonFungibleTokens(nonFungibleTokens[row])
        }
    }

    func ticker(for token: TokenObject) -> CoinTicker? {
        return tickers?[token.contract]
    }

    func canDelete(for row: Int, section: Int) -> Bool {
        let token = item(for: row, section: section)
        switch token {
        case .token(let token):
             return token.isCustom
        case .nonFungibleTokens:
            return false
        }
    }

    var footerTitle: String {
        return NSLocalizedString("tokens.footer.label.title", value: "Tokens will appear automagically. + to add manually.", comment: "")
    }

    var footerTextColor: UIColor {
        return Colors.black
    }

    var footerTextFont: UIFont {
        return UIFont.systemFont(ofSize: 13, weight: .light)
    }
}
