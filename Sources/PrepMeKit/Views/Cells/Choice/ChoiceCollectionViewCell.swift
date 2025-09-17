import UIKit
import SCEPKit

@MainActor
protocol ChoiceCollectionViewCellDelegate: AnyObject {
    func choiceCollectionViewCellCollapse(_ choiceCollectionViewCell: ChoiceCollectionViewCell)
}

class ChoiceCollectionViewCell: UICollectionViewCell {
    
    static func getHeight(
        for width: CGFloat,
        choice: Choice,
        isIndicatorVisible: Bool,
        isCollapseButtonVisible: Bool,
        isExplanationVisible: Bool,
        explanation: String,
        reference: String
    ) -> CGFloat {
        let contentWidth = width - 28
        let titleWidth = contentWidth - (isIndicatorVisible ? 40 : 0)
        let titleHeight = max(24, choice.text.removingHTMLTags().height(withConstrainedWidth: titleWidth, font: SCEPKit.font(ofSize: 16, weight: .medium)))
        
        var height = titleHeight
        if isCollapseButtonVisible {
            height += 22
        }
        if isExplanationVisible {
            height += 8 + explanation.removingHTMLTags().height(withConstrainedWidth: contentWidth, font: SCEPKit.font(ofSize: 14, weight: .medium)) + 16 + "Reference:".height(withConstrainedWidth: contentWidth, font: SCEPKit.font(ofSize: 14, weight: .semiBold)) + 2 + reference.removingHTMLTags().height(withConstrainedWidth: contentWidth, font: SCEPKit.font(ofSize: 14, weight: .regular))
        }
        return height + 24
    }
    
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var titleStackView: UIStackView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var indicatorImageView: UIImageView!
    @IBOutlet private weak var collapseButton: UIButton!
    @IBOutlet private weak var explanationLabel: UILabel!
    @IBOutlet private weak var referenceTitleLabel: UILabel!
    @IBOutlet private weak var referenceLabel: UILabel!
    
    weak var delegate: ChoiceCollectionViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.borderWidth = 2
        stackView.setCustomSpacing(4, after: titleStackView)
        stackView.setCustomSpacing(8, after: collapseButton)
        stackView.setCustomSpacing(16, after: explanationLabel)
        stackView.setCustomSpacing(2, after: referenceTitleLabel)
    }
    
    func setup(with choice: Choice, explanation: String, reference: String) {
        titleLabel.text = choice.text.removingHTMLTags()
        explanationLabel.text = explanation.removingHTMLTags()
        referenceLabel.text = reference.removingHTMLTags()
        deselect()
    }
    
    func deselect() {
        collapseButton.isHidden = true
        indicatorImageView.isHidden = true
        explanationLabel.isHidden = true
        referenceTitleLabel.isHidden = true
        referenceLabel.isHidden = true
        layer.borderColor = UIColor.clear.cgColor
    }
    
    func select() {
        layer.borderColor = UIColor.prepMeAccent.cgColor
    }
    
    func selectCorrect() {
        updateCollapseButton()
        collapseButton.isHidden = false
        indicatorImageView.image = UIImage(resource: .correct)
        indicatorImageView.isHidden = false
        layer.borderColor = UIColor(resource: .correct).cgColor
    }
    
    func selectWrong() {
        indicatorImageView.image = UIImage(resource: .wrong)
        indicatorImageView.isHidden = false
        layer.borderColor = UIColor(resource: .wrong).cgColor
    }
    
    @IBAction private func collapseButtonClicked(_ sender: Any) {
        explanationLabel.isHidden.toggle()
        referenceTitleLabel.isHidden.toggle()
        referenceLabel.isHidden.toggle()
        updateCollapseButton()
        delegate?.choiceCollectionViewCellCollapse(self)
    }
    
    private func updateCollapseButton() {
        collapseButton.setTitle(explanationLabel.isHidden ? "Show explanation" : "Hide explanation", for: .normal)
        collapseButton.setImage(UIImage(resource: explanationLabel.isHidden ? .smallChevronDown : .smallChevronUp), for: .normal)
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
