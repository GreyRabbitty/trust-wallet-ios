// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

struct BalanceViewModel {

    static var formatter: NumberFormatter {
        let formatter = NumberFormatter()
        //TODO: use current locale when available this feature
        formatter.locale = Locale(identifier: "en_US")
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.numberStyle = .currency
        return formatter
    }

    let balance: Balance?
    let rate: CurrencyRate?
    let config: Config

    init(
        balance: Balance? = .none,
        rate: CurrencyRate? = .none,
        config: Config = Config()
    ) {
        self.balance = balance
        self.rate = rate
        self.config = config
    }

    var amount: Double {
        guard let balance = balance else { return 0.00 }
        return balance.amount.doubleValue
    }

    var amountString: String {
        guard let balance = balance else { return "--" }
        guard !balance.isZero else { return "0.00 ETH" }
        return "\(balance.amount) ETH"
    }

    var currencyAmount: String? {
        guard let rate = rate else { return nil }
        guard
            let currentRate = (rate.rates.filter { $0.code == "ETH" }.first),
            currentRate.price > 0,
            amount > 0
        else { return nil }
        let totalAmount = amount * currentRate.price
        return BalanceViewModel.formatter.string(from: NSNumber(value: totalAmount))
    }

    var attributedAmount: NSAttributedString {
        return NSAttributedString(
            string: amountString,
            attributes: attributes(primary: config.isCryptoPrimaryCurrency)
        )
    }

    var attributedCurrencyAmount: NSAttributedString? {
        guard let currencyAmount = currencyAmount else { return nil }
        return NSAttributedString(
            string: currencyAmount,
            attributes: attributes(primary: !config.isCryptoPrimaryCurrency)
        )
    }

    private func attributes(primary: Bool) -> [String: AnyObject] {
        switch (primary, currencyAmount, balance) {
        case (true, .none, .none):
            return largeLabelAttributed
        case (false, .none, .none), (false, .none, .some), (false, .some, .none):
            return largeLabelAttributed
        case (false, .some, .some):
            return smallLabelAttributes
        default: return largeLabelAttributed
        }
    }

    var largeLabelAttributed: [String: AnyObject] {
        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.center
        return [
            NSFontAttributeName: UIFont.systemFont(ofSize: 18, weight: UIFontWeightSemibold),
            NSForegroundColorAttributeName: Colors.lightBlack,
            NSParagraphStyleAttributeName: style,
        ]
    }

    var smallLabelAttributes: [String: AnyObject] {
        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.center
        return [
            NSFontAttributeName: UIFont.systemFont(ofSize: 13, weight: UIFontWeightRegular),
            NSForegroundColorAttributeName: Colors.darkGray,
            NSParagraphStyleAttributeName: style,
        ]
    }
}
