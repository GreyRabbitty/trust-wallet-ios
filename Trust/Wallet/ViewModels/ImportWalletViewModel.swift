// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct ImportWalletViewModel {

    private let config: Config

    init(
        config: Config = Config()
    ) {
        self.config = config
    }

    var title: String {
        return NSLocalizedString("import.navigation.title", value: "Import Wallet", comment: "")
    }

    var keystorePlaceholder: String {
        return NSLocalizedString("Keystore JSON", value: "Keystore JSON", comment: "")
    }

    var mnemonicPlaceholder: String {
        return NSLocalizedString("import.wallet.mnemonic.placeholder", value: "Words separated by a space. (Usually contains 12 words)", comment: "")
    }

    var privateKeyPlaceholder: String {
        return NSLocalizedString("Private Key", value: "Private Key", comment: "")
    }

    var watchAddressPlaceholder: String {
        return String(format: NSLocalizedString("import.wallet.watch.placeholder", value: "%@ Address", comment: ""), config.server.name)
    }
}
