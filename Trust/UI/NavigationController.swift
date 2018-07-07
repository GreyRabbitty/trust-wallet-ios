// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

class NavigationController: UINavigationController {
    @discardableResult
    static func openFormSheet(
        for controller: UIViewController,
        in navigationController: UINavigationController,
        barItem: UIBarButtonItem
    ) -> UIViewController {
        if UIDevice.current.userInterfaceIdiom == .pad {
            controller.navigationItem.leftBarButtonItem = barItem
            let nav = NavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .formSheet
            navigationController.present(nav, animated: true, completion: nil)
        } else {
            navigationController.pushViewController(controller, animated: true)
        }
        return controller
    }

    open override var preferredStatusBarStyle: UIStatusBarStyle {
        var preferredStyle: UIStatusBarStyle
        if
            topViewController is MasterBrowserViewController ||
            topViewController is DarkPassphraseViewController ||
            topViewController is DarkVerifyPassphraseViewController ||
            topViewController is WalletCreatedController
        {
            preferredStyle = .default
        } else {
            preferredStyle = .lightContent
        }
        return preferredStyle
    }
}
