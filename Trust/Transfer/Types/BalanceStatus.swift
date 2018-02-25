// Copyright SIX DAY LLC. All rights reserved.

import Foundation

enum BalanceStatus {
    case ether(etherSufficient: Bool, gasSufficient: Bool)
    case token(tokenSufficient: Bool, gasSufficient: Bool)
}

extension BalanceStatus {

    enum Key {
        case insufficientEther
        case insufficientGas
        case insufficientToken
        case correct

        var string: String {
            switch self {
            case .insufficientEther:
                return "send.error.insufficientEther"
            case .insufficientGas:
                return "send.error.insufficientGas"
            case .insufficientToken:
                return "send.error.insufficientToken"
            case .correct:
                return ""
            }
        }
    }

    var sufficient: Bool {
        switch self {
        case .ether(let etherSufficient, let gasSufficient):
            return etherSufficient && gasSufficient
        case .token(let tokenSufficient, let gasSufficient):
            return tokenSufficient && gasSufficient
        }
    }

    var insufficientTextKey: Key {
        switch self {
        case .ether(let etherSufficient, let gasSufficient):
            if !etherSufficient {
                return .insufficientEther
            }
            if !gasSufficient {
                return .insufficientGas
            }
        case .token(let tokenSufficient, let gasSufficient):
            if !tokenSufficient {
                return .insufficientToken
            }
            if !gasSufficient {
                return .insufficientGas
            }
        }
        return .correct
    }

    var insufficientText: String {
        let key = insufficientTextKey
        switch key {
        case .insufficientEther:
            return NSLocalizedString(key.string, value: "Insufficient ethers", comment: "")
        case .insufficientGas:
            return NSLocalizedString(key.string, value: "Insufficient ethers for gas fee", comment: "")
        case .insufficientToken:
            return NSLocalizedString(key.string, value: "Insufficient tokens", comment: "")
        case .correct:
            return ""
        }
    }
}
