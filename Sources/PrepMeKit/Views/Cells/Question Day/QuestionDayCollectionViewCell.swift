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
        titleLabel.textColor = .prepMeTextColor
        edgeIndicatorView.backgroundColor = .prepMeAccent
        dotIndicatorView.backgroundColor = .prepMeAccent
        dateLabel.textColor = .prepMeTextColor
    }
    
    func disable() {
        imageView.tintColor = .prepMeShade1
        titleLabel.textColor = .prepMeShade1
        edgeIndicatorView.backgroundColor = .prepMeShade2
        dotIndicatorView.backgroundColor = .prepMeShade1
        dateLabel.textColor = .prepMeShade1
    }
    
}
