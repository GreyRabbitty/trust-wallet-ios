// Copyright SIX DAY LLC. All rights reserved.

import Foundation

enum DeviceType: String, Encodable {
    case ios
    case android
}

struct PushDevice: Encodable {
    let deviceID: String
    let token: String
    let wallets: [String]
    let type: DeviceType = .ios
    let preferences: Preferences
}
