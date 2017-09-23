// Copyright SIX DAY LLC, Inc. All rights reserved.

import Foundation
import UIKit

struct TokensViewModel {

    var tokens: [Token] = []

    init(tokens: [Token]) {
        self.tokens = tokens
    }

    var title: String {
        return "Tokens"
    }

    var backgroundColor: UIColor {
        return .white
    }

    var hasContent: Bool {
        return !tokens.isEmpty
    }

    var numberOfSections: Int {
        return 1
    }

    func numberOfItems(for section: Int) -> Int {
        return tokens.count
    }

    func item(for row: Int, section: Int) -> Token {
        return tokens[row]
    }
}
