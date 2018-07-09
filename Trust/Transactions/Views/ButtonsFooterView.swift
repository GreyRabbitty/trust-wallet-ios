// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import UIKit

final class ButtonsFooterView: UIView {

    lazy var sendButton: Button = {
        let sendButton = Button(size: .large, style: .squared)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.layer.cornerRadius = 6
        sendButton.setTitle(R.string.localizable.send(), for: .normal)
        sendButton.accessibilityIdentifier = "send-button"
        sendButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.medium)
        return sendButton
    }()

    lazy var requestButton: Button = {
        let requestButton = Button(size: .large, style: .squared)
        requestButton.translatesAutoresizingMaskIntoConstraints = false
        requestButton.layer.cornerRadius = 6
        requestButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.medium)
        requestButton.setTitle(NSLocalizedString("transactions.receive.button.title", value: "Receive", comment: ""), for: .normal)
        return requestButton
    }()

    init(
        frame: CGRect,
        bottomOffset: CGFloat = 0
    ) {
        super.init(frame: frame)

        let stackView = UIStackView(arrangedSubviews: [
            sendButton,
            requestButton,
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
        stackView.distribution = .fillEqually
        stackView.spacing = 15
        addSubview(stackView)

        backgroundColor = .white
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 0.1

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: layoutGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor, constant: -bottomOffset),
        ])
    }

    func setTopBorder() {
        layer.shadowOffset = CGSize(width: 0, height: -1)
    }

    func setBottomBorder() {
        layer.shadowOffset = CGSize(width: 0.0, height: 1)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
