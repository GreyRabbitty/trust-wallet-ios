// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

struct AccountViewModel {

    let account: Account
    let current: Account?

    init(account: Account, current: Account? = EtherKeystore.current) {
        self.account = account
        self.current = current
    }

    var title: String {
        return account.address.address
    }

    var image: UIImage? {
        if isActive {
            return UIImage.filled(with: Colors.lightBlack)
        }
        return nil
    }

    var isActive: Bool {
        return account == current
    }
}
