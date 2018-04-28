// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import BigInt
import TrustCore

struct MonetaryAmountViewModel {
    let amount: String
    let address: Address?
    let currencyRate: CurrencyRate?
    let formatter: EtherNumberFormatter

    init(
        amount: String,
        address: Address,
        currencyRate: CurrencyRate? = nil,
        formatter: EtherNumberFormatter = .full
    ) {
        self.amount = amount
        self.address = address
        self.currencyRate = currencyRate
        self.formatter = formatter
    }

    var amountCurrency: Double? {
        guard let address = address else {
            return .none
        }
        return currencyRate?.estimate(fee: amount, with: address.eip55String)
    }

    var amountText: String? {
        guard let amountCurrency = amountCurrency,
            let result = currencyRate?.format(fee: amountCurrency) else {
            return .none
        }
        return "(\(result))"
    }
}
