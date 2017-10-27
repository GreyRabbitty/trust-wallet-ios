// Copyright SIX DAY LLC. All rights reserved.

import XCTest
@testable import Trust

class TransactionCoordinatorTests: XCTestCase {
    
    func testShowTokens() {
        let coordinator = TransactionCoordinator(
            session: .make(),
            rootNavigationController: FakeNavigationController(),
            storage: FakeTransactionsStorage()
        )

        coordinator.showTokens(for: .make())

        XCTAssertTrue(coordinator.navigationController.viewControllers[0] is TokensViewController)
    }

    func testShowSettings() {
        let coordinator = TransactionCoordinator(
            session: .make(),
            rootNavigationController: FakeNavigationController(),
            storage: FakeTransactionsStorage()
        )

        coordinator.showSettings()

        XCTAssertTrue((coordinator.navigationController.presentedViewController as? UINavigationController)?.viewControllers[0] is SettingsViewController)
    }

    func testShowSendFlow() {
        let coordinator = TransactionCoordinator(
            session: .make(),
            rootNavigationController: FakeNavigationController(),
            storage: FakeTransactionsStorage()
        )

        coordinator.showPaymentFlow(for: .send(destination: .none), session: .make())

        let controller = (coordinator.navigationController.presentedViewController as? UINavigationController)?.viewControllers[0]

        XCTAssertTrue(controller is SendViewController)
    }

    func testShowRequstFlow() {
        let coordinator = TransactionCoordinator(
            session: .make(),
            rootNavigationController: FakeNavigationController(),
            storage: FakeTransactionsStorage()
        )

        coordinator.showPaymentFlow(for: .request, session: .make())

        let controller = (coordinator.navigationController.presentedViewController as? UINavigationController)?.viewControllers[0]

        XCTAssertTrue(controller is RequestViewController)
    }

    func testShowAccounts() {
        let coordinator = TransactionCoordinator(
            session: .make(),
            rootNavigationController: FakeNavigationController(),
            storage: FakeTransactionsStorage()
        )

        coordinator.showAccounts()

        XCTAssertTrue((coordinator.navigationController.presentedViewController as? UINavigationController)?.viewControllers[0] is AccountsViewController)
    }
}
