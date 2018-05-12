// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import JdenticonSwift
import TrustCore
import UIKit

struct AccountViewModel {
    let identiconSize = 60 as CGFloat
    let wallet: Wallet
    let current: Wallet?
    let walletBalance: Balance?
    let server: RPCServer
    let ensName: String

    init(
        server: RPCServer,
        wallet: Wallet,
        current: Wallet?,
        walletBalance: Balance?,
        ensName: String = ""
    ) {
        self.server = server
        self.wallet = wallet
        self.current = current
        self.walletBalance = walletBalance
        self.ensName = ensName
    }

    var isWatch: Bool {
        return wallet.type == .address(wallet.address)
    }

    var balanceText: String {
        guard let amount = walletBalance?.amountFull else { return "--" }
        return "\(amount) \(server.symbol)"
    }

    var title: String {
        let address = wallet.address.description
        if ensName.isEmpty {
            return address
        }
        return String(format: "%@ (%@...%@)", ensName, String(address.prefix(6)), String(address.suffix(4)))
    }

    var isActive: Bool {
        return wallet == current
    }

    var identicon: UIImage? {
        guard let cgImage = IconGenerator(size: identiconSize, hash: wallet.address.data).render() else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }
}
