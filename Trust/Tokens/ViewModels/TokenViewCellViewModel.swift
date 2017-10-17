// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

struct TokenViewCellViewModel {

    static let numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.minimumFractionDigits = 3
        numberFormatter.maximumFractionDigits = 3
        return numberFormatter
    }()

    let token: Token

    init(token: Token) {
        self.token = token
    }

    var title: String {
        return token.name
    }

    var amount: String {
        let res = pow(10.0, Double(token.decimals))
        let double = NSNumber(value: token.balance / res)
        return TokenViewCellViewModel.numberFormatter.string(from: double)!
    }

    var amountTextColor: UIColor {
        return Colors.black
    }

    var amountFont: UIFont {
        return UIFont.systemFont(ofSize: 17, weight: UIFontWeightMedium)
    }

    var subTitle: String {
        return token.symbol
    }

    var subTitleTextColor: UIColor {
        return Colors.black
    }

    var subTitleFont: UIFont {
        return UIFont.systemFont(ofSize: 13, weight: UIFontWeightRegular)
    }

    var backgroundColor: UIColor {
        return .white
    }

    var image: UIImage? {
        return R.image.ethereumToken()
    }
}
