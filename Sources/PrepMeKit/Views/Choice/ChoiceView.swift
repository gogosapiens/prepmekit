import UIKit

@MainActor
protocol ChoiceViewDelegate: AnyObject {
    func choiceViewDidSelect(_ choiceView: ChoiceView)
    func choiceViewUpOrder(_ choiceView: ChoiceView)
    func choiceViewDownOrder(_ choiceView: ChoiceView)
}

class ChoiceView: UIView {
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var leadingIndexLabel: UILabel!
    @IBOutlet private weak var leadingIndicatorImageView: UIImageView!
    @IBOutlet private weak var titleWebView: WebView!
    @IBOutlet private weak var orderButtonsView: UIView!
    @IBOutlet private weak var upOrderButton: UIButton!
    @IBOutlet private weak var downOrderButton: UIButton!
    @IBOutlet private weak var trailingIndicatorImageView: UIImageView!
    @IBOutlet private weak var trailingIndexView: UIView!
    @IBOutlet private weak var trailingIndexLabel: UILabel!
    @IBOutlet private weak var collapseButton: UIButton!
    @IBOutlet private weak var explanationWebView: WebView!
    @IBOutlet private weak var referenceTitleLabel: UILabel!
    @IBOutlet private weak var referenceLabel: UILabel!
    @IBOutlet private weak var explanationImageView: UIImageView!
    @IBOutlet private weak var explanationImageWebView: WebView!
    @IBOutlet private weak var collapseExplanationImageDescriptionButton: UIButton!
    @IBOutlet private weak var explanationImageDescriptionWebView: WebView!
    private let borderWidth: CGFloat = 2
    private let tapGesture = UITapGestureRecognizer()
    private let dashBorder = CAShapeLayer()
    private var explanation = ""
    private var explanationImage: Question.Image?
    private var questionType: String?
    private var loadExplanationImageTask: Task<Void, Error>?
    
    weak var delegate: ChoiceViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tapGesture.addTarget(self, action: #selector(didTap))
        addGestureRecognizer(tapGesture)
        layer.borderColor = UIColor.clear.cgColor
        layer.borderWidth = borderWidth
        stackView.setCustomSpacing(1, after: titleWebView)
        stackView.setCustomSpacing(5, after: collapseButton)
        stackView.setCustomSpacing(13, after: explanationWebView)
        stackView.setCustomSpacing(2, after: referenceTitleLabel)
        stackView.setCustomSpacing(12, after: referenceLabel)
        stackView.setCustomSpacing(12, after: explanationImageView)
        stackView.setCustomSpacing(12, after: explanationImageWebView)
        stackView.setCustomSpacing(12, after: collapseExplanationImageDescriptionButton)
        titleWebView.isUserInteractionEnabled = false
        titleWebView.setFont(size: 16, weight: .medium)
        explanationWebView.setFont(size: 14, weight: .medium)
        explanationImageWebView.setFont(size: 14, weight: .medium)
        explanationImageDescriptionWebView.setFont(size: 14, weight: .medium)
        layer.addSublayer(dashBorder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        dashBorder.lineWidth = borderWidth
        dashBorder.strokeColor = UIColor(resource: .correct).cgColor
        dashBorder.lineDashPattern = [12, 12] as [NSNumber]
        dashBorder.frame = bounds
        dashBorder.fillColor = nil
        dashBorder.path = UIBezierPath(
            roundedRect: CGRect(
                x: bounds.origin.x + borderWidth / 2,
                y: bounds.origin.y + borderWidth / 2,
                width: bounds.width - borderWidth,
                height: bounds.height - borderWidth
            ),
            cornerRadius: layer.cornerRadius
        ).cgPath
    }
    
    @objc private func didTap() {
        guard questionType != .buildList else { return }
        delegate?.choiceViewDidSelect(self)
    }
    
    func setup(
        with choice: Choice,
        explanation: String,
        reference: String,
        questionType: String?,
        explanationImage: Question.Image?
    ) {
        setup(
            with: choice.text,
            explanation: explanation,
            reference: reference,
            questionType: questionType,
            explanationImage: explanationImage
        )
    }
    
    func setup(
        with text: String,
        explanation: String,
        reference: String,
        questionType: String?,
        explanationImage: Question.Image?
    ) {
        self.questionType = questionType
        titleWebView.setContent(text)
        self.explanation = explanation
        self.explanationImage = explanationImage
        referenceLabel.text = reference.removingHTMLTags()
        deselect()
    }
    
    func setIndex(_ index: Int, of choiceCount: Int) {
        leadingIndexLabel.isHidden = false
        leadingIndexLabel.text = String(index + 1)
        orderButtonsView.isHidden = false
        upOrderButton.tintColor = index > 0 ? .prepMeAccent : .scepShade2
        upOrderButton.isUserInteractionEnabled = index > 0
        downOrderButton.tintColor = index + 1 < choiceCount ? .prepMeAccent : .scepShade2
        downOrderButton.isUserInteractionEnabled = index + 1 < choiceCount
    }
    
    func setTrailingIndex(_ index: Int) {
        trailingIndexView.isHidden = false
        trailingIndexLabel.isHidden = false
        trailingIndexLabel.text = String(index + 1)
    }
    
    func deselect() {
        leadingIndexLabel.isHidden = true
        leadingIndexLabel.textColor = .white
        leadingIndexLabel.backgroundColor = .scepTextColor
        leadingIndexLabel.layer.borderWidth = 0
        leadingIndicatorImageView.isHidden = true
        trailingIndicatorImageView.image = nil
        trailingIndexView.isHidden = true
        orderButtonsView.isHidden = true
        collapseButton.isHidden = true
        explanationWebView.isHidden = true
        referenceTitleLabel.isHidden = true
        referenceLabel.isHidden = true
        explanationImageView.isHidden = true
        explanationImageWebView.isHidden = true
        collapseExplanationImageDescriptionButton.isHidden = true
        explanationImageDescriptionWebView.isHidden = true
        layer.borderColor = UIColor.clear.cgColor
        dashBorder.isHidden = true
        
        switch questionType {
        case .trueFalse:
            leadingIndicatorImageView.image = UIImage(resource: .radioButtonUnchecked)
            leadingIndicatorImageView.isHidden = false
        case .buildList:
            trailingIndicatorImageView.isHidden = true
        default:
            break
        }
    }
    
    func select() {
        switch questionType {
        case .trueFalse:
            leadingIndicatorImageView.image = UIImage(resource: .radioButtonChecked)
        case .buildList:
            break
        default:
            layer.borderColor = UIColor.prepMeAccent.cgColor
            dashBorder.isHidden = true
        }
    }
    
    func selectCorrect() {
        switch questionType {
        case .buildList:
            leadingIndexLabel.textColor = .white
            leadingIndexLabel.backgroundColor = UIColor(resource: .correct)
            trailingIndexView.isHidden = false
            trailingIndexLabel.isHidden = true
            orderButtonsView.isHidden = true
        default:
            trailingIndicatorImageView.image = UIImage(resource: .correct)
            layer.borderColor = UIColor(resource: .correct).cgColor
            dashBorder.isHidden = true
        }
    }
    
    func selectMissedCorrect() {
        trailingIndicatorImageView.image = UIImage(resource: .correct)
        layer.borderColor = UIColor.clear.cgColor
        dashBorder.isHidden = false
    }
    
    func selectWrong() {
        switch questionType {
        case .buildList:
            leadingIndexLabel.textColor = UIColor(resource: .wrong)
            leadingIndexLabel.backgroundColor = .white
            leadingIndexLabel.layer.borderColor = UIColor(resource: .wrong).cgColor
            leadingIndexLabel.layer.borderWidth = 2
            orderButtonsView.isHidden = true
        default:
            trailingIndicatorImageView.image = UIImage(resource: .wrong)
            layer.borderColor = UIColor(resource: .wrong).cgColor
            dashBorder.isHidden = true
        }
    }
    
    func showCollapseButton() {
        updateCollapseButton()
        collapseButton.isHidden = false
        explanationWebView.setContent(explanation)
        if let explanationImage, let url = URL(string: "https://avirtek.mobi/" + explanationImage.url) {
            loadExplanationImage(url: url)
            if !explanationImage.altText.isEmpty {
                explanationImageWebView.setContent(explanationImage.altText)
            }
            if !explanationImage.longAltText.isEmpty {
                explanationImageDescriptionWebView.setContent(explanationImage.longAltText)
            }
        }
    }
    
    private func loadExplanationImage(url: URL) {
        loadExplanationImageTask?.cancel()
        explanationImageView.image = nil
        loadExplanationImageTask = Task {
            let (data, _) = try await URLSession.shared.data(from: url)
            explanationImageView.image = UIImage(data: data)
        }
    }
    
    @IBAction private func collapseButtonClicked(_ sender: Any) {
        explanationWebView.isHidden.toggle()
        if referenceLabel.text?.isEmpty == false {
            referenceTitleLabel.isHidden.toggle()
            referenceLabel.isHidden.toggle()
        }
        if let explanationImage {
            explanationImageView.isHidden.toggle()
            if !explanationImage.altText.isEmpty {
                explanationImageWebView.isHidden.toggle()
            }
            if !explanationImage.longAltText.isEmpty {
                collapseExplanationImageDescriptionButton.isHidden.toggle()
                if collapseExplanationImageDescriptionButton.isHidden {
                    explanationImageDescriptionWebView.isHidden = true
                }
                updateCollapseExplanationImageDescriptionButton()
            }
        }
        updateCollapseButton()
    }
    
    @IBAction private func collapseExplanationImageDescriptionButtonClicked(_ sender: Any) {
        explanationImageDescriptionWebView.isHidden.toggle()
        updateCollapseExplanationImageDescriptionButton()
    }
    
    @IBAction private func upOrderButtonClicked(_ sender: Any) {
        delegate?.choiceViewUpOrder(self)
    }
    
    @IBAction private func downOrderButtonClicked(_ sender: Any) {
        delegate?.choiceViewDownOrder(self)
    }
    
    private func updateCollapseButton() {
        collapseButton.setTitle(explanationWebView.isHidden ? "Show explanation" : "Hide explanation", for: .normal)
        collapseButton.setImage(UIImage(resource: explanationWebView.isHidden ? .smallChevronDown : .smallChevronUp), for: .normal)
    }
    
    private func updateCollapseExplanationImageDescriptionButton() {
        collapseExplanationImageDescriptionButton.setImage(UIImage(resource: explanationImageDescriptionWebView.isHidden ? .smallChevronDown : .smallChevronUp), for: .normal)
    }
    
}
