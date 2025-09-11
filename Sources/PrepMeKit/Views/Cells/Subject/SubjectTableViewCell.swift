import UIKit

class SubjectTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var separatorView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var checkboxImageView: UIImageView!
    
    func setup(title: String, isChecked: Bool, hideSeparator: Bool) {
        titleLabel.text = title
        checkboxImageView.image = UIImage(resource: isChecked ? .checkboxChecked : .checkboxUnchecked)
        separatorView.isHidden = hideSeparator
    }
    
}
