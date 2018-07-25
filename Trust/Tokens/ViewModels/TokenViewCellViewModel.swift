// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import UIKit
import BigInt

struct TokenViewCellViewModel {

    private let shortFormatter = EtherNumberFormatter.short

    let token: TokenObject
    let ticker: CoinTicker?
    let store: TransactionsStorage

    init(
        token: TokenObject,
        ticker: CoinTicker?,
        store: TransactionsStorage
    ) {
        self.token = token
        self.ticker = ticker
        self.store = store
    }

    var title: String {
        return token.title
    }

    var titleFont: UIFont {
        return UIFont.systemFont(ofSize: 17, weight: .medium)
    }

    var titleTextColor: UIColor {
        return Colors.black
    }

    var amount: String {
        return shortFormatter.string(from: BigInt(token.value) ?? BigInt(), decimals: token.decimals)
    }

    var currencyAmount: String? {
        return TokensLayout.cell.totalFiatAmount(token: token)
    }

    var amountFont: UIFont {
        return UIFont.systemFont(ofSize: 17, weight: .medium)
    }

    var currencyAmountFont: UIFont {
        return UIFont.systemFont(ofSize: 13, weight: .regular)
    }

    var backgroundColor: UIColor {
        return .white
    }

    var amountTextColor: UIColor {
        return Colors.black
    }

    var currencyAmountTextColor: UIColor {
        return Colors.lightGray
    }

    // Percent change

    var percentChange: String? {
        return TokensLayout.cell.percentChange(for: ticker)
    }

    var percentChangeColor: UIColor {
        return TokensLayout.cell.percentChangeColor(for: ticker)
    }

    var percentChangeFont: UIFont {
        return UIFont.systemFont(ofSize: 12, weight: .light)
    }

    var placeholderImage: UIImage? {
        return token.placeholder
    }

    // Market Price

    var marketPriceFont: UIFont {
        return UIFont.systemFont(ofSize: 12, weight: .regular)
    }

    var marketPriceTextColor: UIColor {
        return Colors.lightGray
    }

    var marketPrice: String? {
        return TokensLayout.cell.marketPrice(for: ticker)
    }

    var imageURL: URL? {
        return token.imageURL
    }
}
