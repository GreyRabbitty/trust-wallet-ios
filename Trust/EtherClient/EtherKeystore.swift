// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import Geth
import Result
import KeychainSwift
import CryptoSwift

class EtherKeystore: Keystore {

    struct Keys {
        static let keychainKeyPrefix = "trustwallet"
        static let recentlyUsedAddress: String = "recentlyUsedAddress"
    }

    private let keychain: KeychainSwift
    let datadir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]

    let gethKeyStorage: GethKeyStore

    public init(
        keychain: KeychainSwift = KeychainSwift(keyPrefix: Keys.keychainKeyPrefix),
        keyStoreSubfolder: String = "/keystore"
    ) {
        self.keychain = keychain
        self.gethKeyStorage = GethNewKeyStore(self.datadir + keyStoreSubfolder, GethLightScryptN, GethLightScryptP)
    }

    var hasAccounts: Bool {
        return !accounts.isEmpty
    }

    var recentlyUsedAccount: Account? {
        set {
            keychain.set(newValue?.address.address ?? "", forKey: Keys.recentlyUsedAddress)
        }
        get {
            let address = keychain.get(Keys.recentlyUsedAddress)
            return accounts.filter { $0.address.address == address }.first
        }
    }

    static var current: Account? {
        return EtherKeystore().recentlyUsedAccount
    }

    // Async
    func createAccount(with password: String, completion: @escaping (Result<Account, KeyStoreError>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let account = self.createAccout(password: password)
            DispatchQueue.main.async {
                completion(.success(account))
            }
        }
    }

    func importKeystore(value: String, password: String, completion: @escaping (Result<Account, KeyStoreError>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let result = self.importKeystore(value: value, password: password)
            DispatchQueue.main.async {
                switch result {
                case .success(let account):
                    completion(.success(account))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }

    func createAccout(password: String) -> Account {
        let gethAccount = try! gethKeyStorage.newAccount(password)
        let account: Account = .from(account: gethAccount)
        let _ = setPassword(password, for: account)
        return account
    }

    func importKeystore(value: String, password: String) -> Result<Account, KeyStoreError> {
        let data = value.data(using: .utf8)
        do {
            //Check if this account already been imported
            let json = try JSONSerialization.jsonObject(with: data!, options: [])
            if let dict = json as? [String: AnyObject], let address = dict["address"] as? String {
                var error: NSError? = nil
                if gethKeyStorage.hasAddress(GethNewAddressFromHex(address.add0x, &error)) {
                    return (.failure(.duplicateAccount))
                }
            }

            let gethAccount = try gethKeyStorage.importKey(data, passphrase: password, newPassphrase: password)
            let account: Account = .from(account: gethAccount)
            let _ = setPassword(password, for: account)
            return (.success(account))
        } catch {
            return (.failure(.failedToImport(error)))
        }
    }

    func importPrivateKey() -> Account? {
        return nil
//        return Account(
//            address: ""
//        )
    }

    var accounts: [Account] {
        return self.gethAccounts.map { Account(address: Address(address: $0.getAddress().getHex())) }
    }

    var gethAccounts: [GethAccount] {
        var finalAccounts: [GethAccount] = []
        let allAccounts = gethKeyStorage.getAccounts()
        let size = allAccounts?.size() ?? 0

        for i in 0..<size {
            if let account = try! allAccounts?.get(i) {
                finalAccounts.append(account)
            }
        }

        return finalAccounts
    }

    func export(account: Account, password: String, newPassword: String) -> Result<String, KeyStoreError> {
        let result = exportData(account: account, password: password, newPassword: newPassword)
        switch result {
        case .success(let data):
            let string = String(data: data, encoding: .utf8) ?? ""
            return (.success(string))
        case .failure(let error):
            return (.failure(error))
        }
    }

    func exportData(account: Account, password: String, newPassword: String) -> Result<Data, KeyStoreError> {
        let gethAccount = getGethAccount(for: account.address)
        do {
            let data = try gethKeyStorage.exportKey(gethAccount, passphrase: password, newPassphrase: newPassword)
            return (.success(data))
        } catch {
            return (.failure(.failedToDecryptKey))
        }
    }

    func delete(account: Account) -> Result<Void, KeyStoreError> {
        let gethAccount = getGethAccount(for: account.address)
        let password = getPassword(for: account)
        do {
            try gethKeyStorage.delete(gethAccount, passphrase: password)
            return (.success())
        } catch {
            return (.failure(.failedToDeleteAccount))
        }
    }

    func updateAccount(account: Account, password: String, newPassword: String) -> Result<Void, KeyStoreError> {
        let gethAccount = getGethAccount(for: account.address)
        do {
            try gethKeyStorage.update(gethAccount, passphrase: password, newPassphrase: newPassword)
            return (.success())
        } catch {
            return (.failure(.failedToUpdatePassword))
        }
    }

    func signTransaction(
        _ signTransaction: SignTransaction
    ) -> Result<Data, KeyStoreError> {
        let gethAddress = GethNewAddressFromHex(signTransaction.address.address, nil)
        let transaction = GethNewTransaction(
            signTransaction.nonce,
            gethAddress,
            signTransaction.amount,
            signTransaction.speed.gasLimit,
            signTransaction.speed.gasPrice,
            signTransaction.data
        )
        let password = getPassword(for: signTransaction.account)

        let gethAccount = getGethAccount(for: signTransaction.account.address)

        do {
            try gethKeyStorage.unlock(gethAccount, passphrase: password)
            let signedTransaction = try gethKeyStorage.signTx(
                gethAccount,
                tx: transaction,
                chainID: signTransaction.chainID
            )
            let rlp = try signedTransaction.encodeRLP()
            return (.success(rlp))
        } catch {
            return (.failure(.failedToSignTransaction))
        }
    }

    func getPassword(for account: Account) -> String? {
        return keychain.get(account.address.address.lowercased())
    }

    @discardableResult
    func setPassword(_ password: String, for account: Account) -> Bool {
        return keychain.set(password, forKey: account.address.address.lowercased())
    }

    func getGethAccount(for address: Address) -> GethAccount {
        return gethAccounts.filter { Address(address: $0.getAddress().getHex()) == address }.first!
    }
    
    func convertPrivateKeyToKeystoreFile(privateKey: String) {
        
        let password: Array<UInt8> = Array(privateKey.utf8)
        let numberOfIterations = 4096
        do {
            // derive key
            let salt: Array<UInt8> = Array("tkmlidnonknkqgvapjrpdcductebsozn".utf8) // TODO: create random 32 bit salt
            let derivedKey = try PKCS5.PBKDF2(password: password, salt: salt, iterations: numberOfIterations, variant: .sha256).calculate()
            
            // encrypt
            let iv: Array<UInt8> = AES.randomIV(AES.blockSize)
            let aes = try AES(key: Array(derivedKey[..<16]), blockMode: .CTR(iv: iv), padding: .pkcs7)
            let ciphertext = try aes.encrypt(password);
            
            // calculate the mac
            let macData = Array(derivedKey[16...]) + ciphertext
            let mac = SHA3(variant: .keccak256).calculate(for: macData)
            
            /* convert to JSONv3 */
            
            // KDF params
            var kdfParams = [String: String]()
            kdfParams["prf"] = "hmac-sha256"
            kdfParams["c"] = String(numberOfIterations)
            kdfParams["salt"] = salt.toHexString()
            kdfParams["dklen"] = "32"
            
            // cipher params
            var cipherParams = [String: String]()
            cipherParams["iv"] = iv.toHexString()
            
            // crypto struct (combines KDF and cipher params
            var cryptoStruct = [String: Any]()
            cryptoStruct["cipher"] = "aes-128-ctr"
            cryptoStruct["ciphertext"] = ciphertext.toHexString()
            cryptoStruct["cipherparams"] = kdfParams
            cryptoStruct["kdf"] = "pbkdf2"
            cryptoStruct["mac"] = mac.toHexString()
            
            // encrypted key json v3
            var encryptedKeyJSONV3 = [String: Any]()
            encryptedKeyJSONV3["crypto"] = cryptoStruct
            encryptedKeyJSONV3["version"] = 3
            encryptedKeyJSONV3["id"] = 0;  // TODO: where to get ID from?
            
            // TODO: convert to required structure
            
        } catch {
            
            // TODO: proper error management
            print(error)
        }
        
    }
}

extension Account {
    static func from(account: GethAccount) -> Account {
        return Account(
            address: Address(address: account.getAddress().getHex())
        )
    }
}
