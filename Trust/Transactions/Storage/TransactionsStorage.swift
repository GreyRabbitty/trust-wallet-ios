// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import RealmSwift

class TransactionsStorage {

    let realm: Realm
    let current: Account
    let chainID: Int

    init(
        configuration: Realm.Configuration = .defaultConfiguration,
        current: Account,
        chainID: Int
    ) {
        self.realm = try! Realm(configuration: configuration)
        self.current = current
        self.chainID = chainID
    }

    var count: Int {
        return objects.count
    }

    var objects: [Transaction] {
        return realm.objects(Transaction.self).sorted(byKeyPath: "date", ascending: true).filter { $0.owner == current.address.address && chainID == $0.chainID }
    }

    func get(forPrimaryKey: String) -> Transaction? {
        return realm.object(ofType: Transaction.self, forPrimaryKey: forPrimaryKey)
    }

    @discardableResult
    func add(_ items: [Transaction]) -> [Transaction] {
        realm.beginWrite()
        realm.add(items, update: true)
        try! realm.commitWrite()
        return items
    }

    func delete(_ items: [Transaction]) {
        try! realm.write {
            realm.delete(items)
        }
    }

    func deleteAll() {
        let objects = realm.objects(Transaction.self)
        try! realm.write {
            realm.delete(objects)
        }
    }

    func delete(for account: Account) {
        let objects = realm.objects(Transaction.self).filter { $0.owner == account.address.address }
        try! realm.write {
            realm.delete(objects)
        }
    }
}
