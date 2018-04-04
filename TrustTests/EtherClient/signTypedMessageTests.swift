// Copyright SIX DAY LLC. All rights reserved.

import XCTest
@testable import Trust
import TrustCore
import TrustKeystore
import KeychainSwift

class signTypedMessageTests: XCTestCase {

    var account: Account!
    let keystore = FakeEtherKeystore()

    override func setUp() {
        super.setUp()
        let privateKeyResult = keystore.convertPrivateKeyToKeystoreFile(privateKey: "0x4c0883a69102937d6231471b5dbb6204fe5129617082792ae468d01a3f362318", passphrase: TestKeyStore.password)
        guard case let .success(keystoreString) = privateKeyResult else {
            return XCTFail()
        }

        let result = keystore.importKeystore(
            value: keystoreString.jsonString!,
            password: TestKeyStore.password,
            newPassword: TestKeyStore.password
        )

        guard case let .success(account) = result else {
            return XCTFail()
        }
        self.account = account
    }

    func testValue_none() {
        let typedData = EthTypedData(type: "string", name: "test test", value: .none)
        let signResult = keystore.signTypedMessage([typedData], for: account)
        guard case let .success(data) = signResult else {
            return XCTFail()
        }
        XCTAssertEqual(data.hexEncoded, "0xd8cb0766acdfeb460b3e88173d71e223e31a442d468a6ceec85eb60b2cdf69dd62cc0a14e8c205eed582d47fac726850e43149844c81965a18ddee7a627c6ffb1b")
    }

    func testType_uint_Value_uint() {
        // from https://beta.adex.network/
        let typedData = EthTypedData(type: "uint", name: "Auth token", value: .uint(value: 1498316044249108))

        let signResult = keystore.signTypedMessage([typedData], for: account)
        guard case let .success(data) = signResult else {
            return XCTFail()
        }
        XCTAssertEqual(data.hexEncoded, "0xa1f639ae9e97401030fb4205749fe8b8e72602624aa92aa0558129b345e9546c42f3bcb7b71c83b7474cb93d83913249708570af9120cf9655775fea9571e0481b")
    }

    func testType_uint_Value_string() {
        // from https://beta.adex.network/
        let typedData = EthTypedData(type: "uint", name: "Auth token", value: .string(value: "1498316044249108"))

        let signResult = keystore.signTypedMessage([typedData], for: account)
        guard case let .success(data) = signResult else {
            return XCTFail()
        }
        XCTAssertEqual(data.hexEncoded, "0xa1f639ae9e97401030fb4205749fe8b8e72602624aa92aa0558129b345e9546c42f3bcb7b71c83b7474cb93d83913249708570af9120cf9655775fea9571e0481b")
    }

    func testType_bool_Value_bool() {
        let typedData = EthTypedData(type: "bool", name: "email valid", value: .bool(value: false))
        let signResult = keystore.signTypedMessage([typedData], for: account)
        guard case let .success(data) = signResult else {
            return XCTFail()
        }
        XCTAssertEqual(data.hexEncoded, "0x1df23825a6c4ea9b1782754da23c21c6af1732fe614cbcdf34a4daefbaddf47c444891aad02c2d4bab0df228fb4852d6620d624a9848e432f7141fe5a89e7e171c")
    }

    func testType_address_Value_string() {
        let typedData = EthTypedData(type: "address", name: "my address", value: .address(value: "0x2c7536e3605d9c16a7a3d7b1898e529396a65c23"))
        let signResult = keystore.signTypedMessage([typedData], for: account)
        guard case let .success(data) = signResult else {
            return XCTFail()
        }
        XCTAssertEqual(data.hexEncoded, "0xe218514cddfeba69a1fe7fac5af54193e357e8fb5644239045ed65e4e950d564412c6bf6d571fafb73bdd23ef71e8269242b001ca3ecb1a6661fcb70eaacf25c1b")
    }

    func testType_string_Value_string() {
        let typedData = EthTypedData(type: "string", name: "This is a message", value: .string(value: "hello bob"))
        let signResult = keystore.signTypedMessage([typedData], for: account)
        guard case let .success(data) = signResult else {
            return XCTFail()
        }
        XCTAssertEqual(data.hexEncoded, "0x8b5194f65b8f2fb8ef110391bcecde9bc97a41dae833c69aa1f6486d910a7d870056f784a386d7a9416315692e0da7a78702d95d308b4381c21d60d93dbc7e061c")
    }

    func testType_int_Value_int() {
        let typedData = EthTypedData(type: "int32", name: "how much?", value: .int(value: 1200))
        let signResult = keystore.signTypedMessage([typedData], for: account)
        guard case let .success(data) = signResult else {
            return XCTFail()
        }
        XCTAssertEqual(data.hexEncoded, "0xe6d4d981485013055ee978c39cf9c18096b4e05bc0471de72377db9b392c7582276d2d8e7b6329f784aac8fbd42417c74906285e072019e025883e52f94a169d1c")
    }

    func testType_bytes_Value_string() {
        let typedData = EthTypedData(type: "bytes", name: "your address", value: .string(value: "0x2c7536e3605d9c16a7a3d7b1898e529396a65c23"))
        let signResult = keystore.signTypedMessage([typedData], for: account)
        guard case let .success(data) = signResult else {
            return XCTFail()
        }

        XCTAssertEqual(data.hexEncoded, "0x5da07ffb693a23caced43cb9056667a32078d64b24aa2591d2b9c56527b6556e29fbe0807dee0d55c16e85d83edc7bbe972234fa5580a4f4f23f0280c875c8461c")
    }
}
