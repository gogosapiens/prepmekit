import UIKit

class TitleTableViewHeader: UITableViewHeaderFooterView {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var bottomConstraintTitleLabel: NSLayoutConstraint!
    
    func setup(title: String, font: UIFont, color: UIColor, bottomPadding: CGFloat) {
        titleLabel.text = title
        titleLabel.font = font
        titleLabel.textColor = color
        bottomConstraintTitleLabel.constant = bottomPadding
    }
    
}
