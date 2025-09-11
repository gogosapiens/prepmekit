import UIKit
import SCEPKit

class ChoiceResultCollectionViewCell: UICollectionViewCell {
    
    static func getHeight(for width: CGFloat, question: Question) -> CGFloat {
        let contentWidth = width - 28
        let subjectWidth = contentWidth - 40
        let subjectHeight = max(24, question.subject.name.height(withConstrainedWidth: subjectWidth, font: SCEPKit.font(ofSize: 12, weight: .medium)))
        let questionHeight = question.prompt.removingHTMLTags().height(withConstrainedWidth: contentWidth, font: SCEPKit.font(ofSize: 14, weight: .medium))
        return subjectHeight + 8 + questionHeight + 24
    }
    
    @IBOutlet private weak var subjectLabel: UILabel!
    @IBOutlet private weak var indicatorImageView: UIImageView!
    @IBOutlet private weak var questionLabel: UILabel!
    
    func setup(question: Question, isCorrect: Bool) {
        subjectLabel.text = question.subject.name
        indicatorImageView.image = UIImage(resource: isCorrect ? .correct : .wrong)
        questionLabel.text = question.prompt.removingHTMLTags()
    }
    
}
