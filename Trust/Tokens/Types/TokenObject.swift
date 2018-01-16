// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import RealmSwift
import BigInt
import TrustKeystore

class TokenObject: Object {
    @objc dynamic var contract: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var symbol: String = ""
    @objc dynamic var decimals: Int = 0
    @objc dynamic var value: String = ""
    @objc dynamic var isCustom: Bool = false
    @objc dynamic var isDisabled: Bool = false
    @objc dynamic var internalType: Int = TokenType.ether.rawValue

    convenience init(
        contract: String = "",
        name: String = "",
        symbol: String = "",
        decimals: Int = 0,
        value: String,
        isCustom: Bool = false,
        isDisabled: Bool = false,
        type: TokenType = .token
    ) {
        self.init()
        self.contract = contract
        self.name = name
        self.symbol = symbol
        self.decimals = decimals
        self.value = value
        self.isCustom = isCustom
        self.isDisabled = isDisabled
        self.internalType = type.rawValue
    }

    var address: Address {
        return Address(string: contract)!
    }

    var valueBigInt: BigInt {
        return BigInt(value) ?? BigInt()
    }

    var type: TokenType {
        return TokenType(int: internalType)
    }

    override static func primaryKey() -> String? {
        return "contract"
    }

    override static func ignoredProperties() -> [String] {
        return ["type"]
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? TokenObject else { return false }
        return object.contract == self.contract
    }
}
