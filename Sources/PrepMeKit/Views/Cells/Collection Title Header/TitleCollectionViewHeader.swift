import UIKit

class TitleCollectionViewHeader: UICollectionReusableView {
    
    @IBOutlet private weak var titleLabel: UILabel!
    
    func setup(title: String) {
        titleLabel.text = title
    }
    
}
