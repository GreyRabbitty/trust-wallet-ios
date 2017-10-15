// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

class TransactionsFooterView: UIView {

    lazy var sendButton: Button = {
        let sendButton = Button(size: .normal, style: .squared)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.layer.cornerRadius = 6
        sendButton.setTitle(NSLocalizedString("Generic.Send", value: "Send", comment: ""), for: .normal)
        sendButton.backgroundColor = Colors.blue
        return sendButton
    }()

    lazy var requestButton: Button = {
        let requestButton = Button(size: .normal, style: .squared)
        requestButton.translatesAutoresizingMaskIntoConstraints = false
        requestButton.layer.cornerRadius = 6
        requestButton.backgroundColor = Colors.blue
        requestButton.setTitle(NSLocalizedString("Generic.Request", value: "Request", comment: ""), for: .normal)
        return requestButton
    }()

    override init(frame: CGRect) {
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
        layer.shadowOffset = CGSize(width: 0, height: -1)
        layer.shadowRadius = 0.1

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: layoutGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor),
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
