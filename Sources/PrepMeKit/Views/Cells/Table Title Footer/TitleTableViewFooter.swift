import UIKit

class TitleTableViewFooter: UITableViewHeaderFooterView {
    
    @IBOutlet private weak var titleLabel: UILabel!
    
    func setup(title: String) {
        titleLabel.text = title
    }
    
}
