import UIKit

@MainActor
protocol PrepContentTableViewCellDelegate: AnyObject {
    func prepContentTableViewCellLearnMoreClicked(_ prepContentTableViewCell: PrepContentTableViewCell)
}

class PrepContentTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    weak var delegate: PrepContentTableViewCellDelegate?
    
    func setup(text: String) {
        descriptionLabel.text = text
    }
    
    @IBAction private func learnMoreClicked(_ sender: Any) {
        delegate?.prepContentTableViewCellLearnMoreClicked(self)
    }
    
}
