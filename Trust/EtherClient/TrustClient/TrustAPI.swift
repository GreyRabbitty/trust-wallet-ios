// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import Moya

enum TrustAPI {

    case getTransactions(server: RPCServer, address: String, startBlock: Int, page: Int, contract: String?)

    case getTransaction(server: RPCServer, ID: String)

    // all
    case prices(TokensPrice)

    case getAllTransactions(addresses: [String: String])
    case search(token: String)
    case assets(address: String)

    case getTokens(address: [String])

    case register(device: PushDevice)
    case unregister(device: PushDevice)
}

struct TokensPrice: Encodable {
    let currency: String
    let tokens: [TokenPrice]
}

struct TokenPrice: Encodable {
    let contract: String
    let symbol: String
}

extension TrustAPI: TargetType {

    var baseURL: URL { return Constants.trustAPI }

    var path: String {
        switch self {
        case .prices:
            return "/tokenPrices"
        case .getTransactions(let value):
            return "/\(value.server.id)/transactions"
        case .getTokens:
            return "/tokens"
        case .getAllTransactions:
            return "/transactions"
        case .getTransaction(let value):
            return "/\(value.server.id)/transactions/\(value.ID)"
        case .register:
            return "/push/register"
        case .unregister:
            return "/push/unregister"
        case .assets:
            return "/assets"
        case .search:
            return "/tokens/list"
        }
    }

    var method: Moya.Method {
        switch self {
        case .prices: return .post
        case .getTransactions: return .get
        case .getTokens: return .post
        case .getTransaction: return .get
        case .getAllTransactions: return .post
        case .register: return .post
        case .unregister: return .post
        case .assets: return .get
        case .search: return .get
        }
    }

    var task: Task {
        switch self {
        case .prices(let tokensPrice):
            return .requestJSONEncodable(tokensPrice)
        case .getTransactions(_, let address, let startBlock, let page, let contract):
            var params: [String: Any] = ["address": address, "startBlock": startBlock, "page": page]
            if let transactionContract = contract {
                params["contract"] = transactionContract
            }
            return .requestParameters(parameters: params, encoding: URLEncoding())
        case .getAllTransactions(let addresses):
            return .requestParameters(parameters: ["address": addresses], encoding: URLEncoding())
        case .getTokens(let value):
            return .requestParameters(parameters: [
                "60": value,
            ], encoding: URLEncoding())
        case .getTransaction:
            return .requestPlain
        case .register(let device):
            return .requestJSONEncodable(device)
        case .unregister(let device):
            return .requestJSONEncodable(device)
        case .assets(let value):
            return .requestParameters(parameters: ["address": value], encoding: URLEncoding())
        case .search(let value):
            return .requestParameters(parameters: ["query": value], encoding: URLEncoding())
        }
    }

    var sampleData: Data {
        return Data()
    }

    var headers: [String: String]? {
        return [
            "Content-type": "application/json",
            "client": Bundle.main.bundleIdentifier ?? "",
            "client-build": Bundle.main.buildNumber ?? "",
        ]
    }
}
