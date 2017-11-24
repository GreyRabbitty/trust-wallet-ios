// Copyright SIX DAY LLC. All rights reserved.

import Foundation

enum TransferType {
    case ether(destination: Address?)
    case token(Token)
    case exchange(from: SubmitExchangeToken, to: SubmitExchangeToken)
}

extension TransferType {
    func symbol(server: RPCServer) -> String {
        switch self {
        case .ether:
            return server.symbol
        case .token(let token):
            return token.symbol
        case .exchange: return "--"
        }
    }
}
