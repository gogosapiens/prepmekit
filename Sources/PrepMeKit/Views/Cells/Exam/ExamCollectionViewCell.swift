import UIKit

class ExamCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    func setup(exam: Exam, isSelected: Bool) {
        titleLabel.text = exam.name
        subtitleLabel.text = exam.descriptiveName
        descriptionLabel.text = "\(exam.questionCount) questions, \(exam.subjects.count) subjects"
        layer.borderColor = UIColor.prepMeAccent.cgColor
        layer.borderWidth = isSelected ? 2 : 0
        titleLabel.textColor = isSelected ? .prepMeAccent : .scepTextColor
    }
    
    override func systemLayoutSizeFitting(
        _ targetSize: CGSize,
        withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
        verticalFittingPriority: UILayoutPriority
    ) -> CGSize {
        return super.systemLayoutSizeFitting(
            CGSize(width: targetSize.width, height: .greatestFiniteMagnitude),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
    }
    
}
