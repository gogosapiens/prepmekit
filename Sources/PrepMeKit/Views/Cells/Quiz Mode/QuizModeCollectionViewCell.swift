import UIKit
import SCEPKit

class QuizModeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var premiumView: UIView!
    
    func setup(with quizMode: QuizMode) {
        imageView.image = quizMode.image
        titleLabel.text = quizMode.title
        premiumView.isHidden = !quizMode.isPremium || SCEPKit.isPremium
    }
    
}
