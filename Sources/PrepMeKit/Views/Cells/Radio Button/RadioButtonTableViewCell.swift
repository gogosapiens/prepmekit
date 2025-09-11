import UIKit

class RadioButtonTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var separatorView: UIView!
    @IBOutlet private weak var radioButtonImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    
    func setup(title: String, isChecked: Bool, hideSeparator: Bool) {
        titleLabel.text = title
        radioButtonImageView.image = UIImage(resource: isChecked ? .radioButtonChecked : .radioButtonUnchecked)
        separatorView.isHidden = hideSeparator
    }
    
}
