// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import BigInt
import TrustCore

struct UnconfirmedTransaction {
    let transferType: TransferType
    let value: BigInt
    let to: Address?
    let data: Data?

    let gasLimit: BigInt?
    let gasPrice: BigInt?
    let nonce: BigInt?
}
