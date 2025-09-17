import UIKit

class QuestionDayCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var edgeIndicatorView: UIView!
    @IBOutlet private weak var dotIndicatorView: UIView!
    @IBOutlet private weak var dateLabel: UILabel!
    
    func setup(date: Date) {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("dd MMMM")
        formatter.locale = Locale(identifier: "en_US")
        dateLabel.text = formatter.string(from: date)
    }
    
    func enable() {
        imageView.tintColor = .prepMeAccent
        titleLabel.textColor = .scepTextColor
        edgeIndicatorView.backgroundColor = .prepMeAccent
        dotIndicatorView.backgroundColor = .prepMeAccent
        dateLabel.textColor = .scepTextColor
    }
    
    func disable() {
        imageView.tintColor = .scepShade1
        titleLabel.textColor = .scepShade1
        edgeIndicatorView.backgroundColor = .scepShade2
        dotIndicatorView.backgroundColor = .scepShade1
        dateLabel.textColor = .scepShade1
    }
    
}
