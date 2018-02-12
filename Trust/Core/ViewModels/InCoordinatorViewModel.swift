// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct InCoordinatorViewModel {

    let config: Config

    init(config: Config) {
        self.config = config
    }

    var tokensAvailable: Bool {
        switch config.server {
        case .main, .classic, .kovan, .ropsten, .rinkeby, .poa, .sokol, .custom: return true
        case .callisto: return false
        }
    }

    var canActivateDebugMode: Bool {
        return config.server.isTestNetwork
    }
}
