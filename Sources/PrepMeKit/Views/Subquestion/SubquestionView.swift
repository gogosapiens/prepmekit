import UIKit

@MainActor
protocol SubquestionViewDelegate: AnyObject {
    func subquestionView(_ subquestionView: SubquestionView, didSelect answerIndex: Int)
}

class SubquestionView: UIView {
    @IBOutlet private weak var titleWebView: WebView!
    @IBOutlet private weak var accessoryImageView: UIImageView!
    @IBOutlet private weak var answersStackView: UIStackView!
    private let tapGesture = UITapGestureRecognizer()
    
    weak var delegate: SubquestionViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tapGesture.addTarget(self, action: #selector(didTap))
        addGestureRecognizer(tapGesture)
        layer.borderColor = UIColor.clear.cgColor
        layer.borderWidth = 2
        titleWebView.isUserInteractionEnabled = false
        titleWebView.setFont(size: 16, weight: .semibold)
    }
    
    @objc private func didTap() {
        answersStackView.isHidden.toggle()
        updateAccessory()
    }
    
    func setup(with text: String, answers: [String], isMultipleCorrectAnswer: Bool) {
        titleWebView.setContent(text)
        answersStackView.isHidden = true
        updateAccessory()
        reloadAnswers(answers, isMultipleCorrectAnswer: isMultipleCorrectAnswer)
        deselect()
    }
    
    private func updateAccessory() {
        accessoryImageView.image = UIImage(resource: answersStackView.isHidden ? .chevronDown : .chevronUp)
    }
    
    private func reloadAnswers(_ answers: [String], isMultipleCorrectAnswer: Bool) {
        for (index, answer) in answers.enumerated() {
            let subquestionAnswerView = (answersStackView.arrangedSubviews[safe: index] as? SubquestionAnswerView) ?? .instantiate()
            subquestionAnswerView.setup(
                with: answer,
                isMultipleCorrectAnswer: isMultipleCorrectAnswer,
                hideSeparator: index == 0
            )
            subquestionAnswerView.delegate = self
            
            if subquestionAnswerView.superview == nil {
                answersStackView.addArrangedSubview(subquestionAnswerView)
            }
        }
        
        answersStackView.arrangedSubviews.dropFirst(answers.count).forEach { $0.removeFromSuperview() }
    }
    
    func deselect() {
        layer.borderColor = UIColor.clear.cgColor
    }
    
    func selectCorrect() {
        layer.borderColor = UIColor(resource: .correct).cgColor
    }
    
    func selectWrong() {
        layer.borderColor = UIColor(resource: .wrong).cgColor
    }
    
    func deselectAnswer(index: Int) {
        getSubquestionAnswerView(at: index)?.deselect()
    }
    
    func selectAnswer(index: Int) {
        getSubquestionAnswerView(at: index)?.select()
    }
    
    func selectCorrectAnswer(index: Int) {
        getSubquestionAnswerView(at: index)?.selectCorrect()
    }
    
    func selectMissedCorrectAnswer(index: Int) {
        getSubquestionAnswerView(at: index)?.selectMissedCorrect()
    }
    
    func selectWrongAnswer(index: Int) {
        getSubquestionAnswerView(at: index)?.selectWrong()
    }
    
    func crossOutAnswer(index: Int) {
        getSubquestionAnswerView(at: index)?.crossOutText()
    }
    
    private func getSubquestionAnswerView(at index: Int) -> SubquestionAnswerView? {
        return answersStackView.arrangedSubviews[safe: index] as? SubquestionAnswerView
    }
    
}

extension SubquestionView: SubquestionAnswerViewDelegate {
    
    func subquestionAnswerViewDidSelect(_ subquestionAnswerView: SubquestionAnswerView) {
        guard let index = answersStackView.arrangedSubviews.firstIndex(of: subquestionAnswerView) else { return }
        delegate?.subquestionView(self, didSelect: index)
    }
    
}
