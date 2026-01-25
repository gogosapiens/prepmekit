import UIKit

@MainActor
protocol ChoiceViewDelegate: AnyObject {
    func choiceViewDidSelect(_ choiceView: ChoiceView)
}

class ChoiceView: UIView {
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var titleWebView: WebView!
    @IBOutlet private weak var indicatorImageView: UIImageView!
    @IBOutlet private weak var collapseButton: UIButton!
    @IBOutlet private weak var explanationWebView: WebView!
    @IBOutlet private weak var referenceTitleLabel: UILabel!
    @IBOutlet private weak var referenceLabel: UILabel!
    private let tapGesture = UITapGestureRecognizer()
    private var explanation = ""
    
    weak var delegate: ChoiceViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tapGesture.addTarget(self, action: #selector(didTap))
        addGestureRecognizer(tapGesture)
        layer.borderColor = UIColor.clear.cgColor
        layer.borderWidth = 2
        stackView.setCustomSpacing(1, after: titleWebView)
        stackView.setCustomSpacing(5, after: collapseButton)
        stackView.setCustomSpacing(13, after: explanationWebView)
        stackView.setCustomSpacing(2, after: referenceTitleLabel)
        titleWebView.isUserInteractionEnabled = false
        titleWebView.setFont(size: 16, weight: .medium)
        explanationWebView.setFont(size: 14, weight: .medium)
    }
    
    @objc private func didTap() {
        delegate?.choiceViewDidSelect(self)
    }
    
    func setup(with choice: Choice, explanation: String, reference: String) {
        titleWebView.setContent(choice.text)
        self.explanation = explanation
        referenceLabel.text = reference.removingHTMLTags()
        deselect()
    }
    
    func deselect() {
        collapseButton.isHidden = true
        indicatorImageView.image = nil
        explanationWebView.isHidden = true
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
        explanationWebView.setContent(explanation)
        layer.borderColor = UIColor(resource: .correct).cgColor
    }
    
    func selectWrong() {
        indicatorImageView.image = UIImage(resource: .wrong)
        layer.borderColor = UIColor(resource: .wrong).cgColor
    }
    
    @IBAction private func collapseButtonClicked(_ sender: Any) {
        explanationWebView.isHidden.toggle()
        if referenceLabel.text?.isEmpty == false {
            referenceTitleLabel.isHidden.toggle()
            referenceLabel.isHidden.toggle()
        }
        updateCollapseButton()
    }
    
    private func updateCollapseButton() {
        collapseButton.setTitle(explanationWebView.isHidden ? "Show explanation" : "Hide explanation", for: .normal)
        collapseButton.setImage(UIImage(resource: explanationWebView.isHidden ? .smallChevronDown : .smallChevronUp), for: .normal)
    }
    
}
