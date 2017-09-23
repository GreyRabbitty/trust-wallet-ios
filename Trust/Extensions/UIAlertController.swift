// Copyright SIX DAY LLC, Inc. All rights reserved.

import Foundation
import UIKit
import Result

extension UIAlertController {

    static func askPassword(
        title: String = "Enter password for you wallet",
        message: String = "",
        completion: @escaping (Result<String, ConfirmationError>) -> Void
    ) -> UIAlertController {
        let alertController = UIAlertController(
            title: "Enter password for you wallet",
            message: message,
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ -> Void in
            let textField = alertController.textFields![0] as UITextField
            let password = textField.text ?? ""
            completion(.success(password))
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            completion(.failure(ConfirmationError.cancel))
        }))
        alertController.addTextField(configurationHandler: {(textField: UITextField!) -> Void in
            textField.placeholder = "Enter Password"
        })
        return alertController
    }
}
