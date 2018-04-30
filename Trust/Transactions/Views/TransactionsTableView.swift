// Copyright SIX DAY LLC. All rights reserved.

import UIKit

class TransactionsTableView: UITableView {

    init() {
        super.init(frame: .zero, style: .plain)

        separatorStyle = .singleLine
        separatorColor = StyleLayout.TableView.separatorColor
        backgroundColor = .white
        rowHeight = TransactionsLayout.tableView.height
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
