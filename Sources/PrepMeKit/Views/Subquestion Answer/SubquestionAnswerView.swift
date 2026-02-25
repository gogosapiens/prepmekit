import UIKit

@MainActor
protocol SubquestionAnswerViewDelegate: AnyObject {
    func subquestionAnswerViewDidSelect(_ subquestionAnswerView: SubquestionAnswerView)
}

class SubquestionAnswerView: UIView {
    @IBOutlet private weak var separatorView: UIView!
    @IBOutlet private weak var accessoryImageView: UIImageView!
    @IBOutlet private weak var titleWebView: WebView!
    private let tapGesture = UITapGestureRecognizer()
    private var isMultipleCorrectAnswer = false
    
    weak var delegate: SubquestionAnswerViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tapGesture.addTarget(self, action: #selector(didTap))
        addGestureRecognizer(tapGesture)
        titleWebView.isUserInteractionEnabled = false
        titleWebView.setFont(size: 16, weight: .medium)
    }
    
    @objc private func didTap() {
        delegate?.subquestionAnswerViewDidSelect(self)
    }
    
    func setup(with text: String, isMultipleCorrectAnswer: Bool, hideSeparator: Bool) {
        titleWebView.setContent(text)
        self.isMultipleCorrectAnswer = isMultipleCorrectAnswer
        separatorView.isHidden = hideSeparator
        deselect()
    }
    
    func deselect() {
        if isMultipleCorrectAnswer {
            accessoryImageView.image = UIImage(resource: .checkboxUnchecked)
        } else {
            accessoryImageView.image = UIImage(resource: .radioButtonUnchecked)
        }
    }
    
    func select() {
        accessoryImageView.tintColor = .prepMeAccent
        if isMultipleCorrectAnswer {
            accessoryImageView.image = UIImage(resource: .checkboxChecked)
        } else {
            accessoryImageView.image = UIImage(resource: .radioButtonChecked)
        }
    }
    
    func selectCorrect() {
        accessoryImageView.tintColor = UIColor(resource: .correct)
        if isMultipleCorrectAnswer {
            accessoryImageView.image = UIImage(resource: .checkboxChecked)
        } else {
            accessoryImageView.image = UIImage(resource: .radioButtonChecked)
        }
    }
    
    func selectMissedCorrect() {
        accessoryImageView.tintColor = UIColor(resource: .correct)
        if isMultipleCorrectAnswer {
            accessoryImageView.image = UIImage(resource: .checkboxCheckedOutline)
        }
    }
    
    func selectWrong() {
        accessoryImageView.tintColor = UIColor(resource: .wrong)
        if isMultipleCorrectAnswer {
            accessoryImageView.image = UIImage(resource: .checkboxChecked)
        } else {
            accessoryImageView.image = UIImage(resource: .radioButtonChecked)
        }
    }
    
    func crossOutText() {
        titleWebView.crossOutText()
    }
    
}
