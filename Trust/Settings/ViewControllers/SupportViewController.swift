// Copyright DApps Platform Inc. All rights reserved.

import Foundation

import UIKit
import Eureka
import MessageUI

protocol SupportViewControllerDelegate: class {
    func didPressURL(_ url: URL, in controller: SupportViewController)
}

final class SupportViewController: FormViewController {

    let viewModel = SupportViewModel()
    weak var delegate: SupportViewControllerDelegate?

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = viewModel.title

        form +++ Section()

            <<< link(
                title: R.string.localizable.settingsFaqButtonTitle(),
                value: "https://trustwalletapp.com/faq.html",
                image: R.image.settings_colorful_faq()
            )

            <<< link(
                title: R.string.localizable.settingsPrivacyTitle(),
                value: "https://trustwalletapp.com/privacy-policy.html",
                image: R.image.settings_colorful_privacy_and_policy()
            )

            <<< link(
                title: R.string.localizable.settingsTermsOfServiceButtonTitle(),
                value: "https://trustwalletapp.com/terms.html",
                image: R.image.settings_colorful_terms_of_service()
            )

            <<< AppFormAppearance.button { button in
                button.title = R.string.localizable.settingsEmailUsButtonTitle()
            }.onCellSelection { [weak self] _, _  in
                self?.sendUsEmail()
            }.cellSetup { cell, _ in
                cell.imageView?.image = R.image.settings_colorful_email()
            }
    }

    private func link(
        title: String,
        value: String,
        image: UIImage?
    ) -> ButtonRow {
        return AppFormAppearance.button {
            $0.title = title
            $0.value = value
        }.onCellSelection { [weak self] (_, row) in
            guard let `self` = self, let value = row.value, let url = URL(string: value) else { return }
            self.delegate?.didPressURL(url, in: self)
        }.cellSetup { cell, _ in
            cell.imageView?.image = image
        }
    }

    func sendUsEmail() {
        let composerController = MFMailComposeViewController()
        composerController.mailComposeDelegate = self
        composerController.setToRecipients([Constants.supportEmail])
        composerController.setSubject(R.string.localizable.settingsFeedbackEmailTitle())
        composerController.setMessageBody(emailTemplate(), isHTML: false)

        if MFMailComposeViewController.canSendMail() {
            present(composerController, animated: true, completion: nil)
        }
    }

    private func emailTemplate() -> String {
        return """
        \n\n\n

        Helpful information to developers:
        iOS Version: \(UIDevice.current.systemVersion)
        Device Model: \(UIDevice.current.model)
        Trust Version: \(Bundle.main.fullVersion)
        Current locale: \(Locale.preferredLanguages.first ?? "")
        """
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SupportViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
