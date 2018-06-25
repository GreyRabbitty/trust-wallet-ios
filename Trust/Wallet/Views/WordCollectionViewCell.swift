// Copyright SIX DAY LLC. All rights reserved.

import UIKit

class WordCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var wordLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        layer.borderColor = Colors.lightGray.cgColor
        layer.borderWidth = 0.5
        layer.cornerRadius = 4
    }
}
