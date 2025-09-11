import UIKit

@MainActor
protocol QuitQuizControllerDelegate: AnyObject {
    func quitQuizControllerContinue(_ quitQuizController: QuitQuizController)
    func quitQuizControllerQuit(_ quitQuizController: QuitQuizController)
    func quitQuizControllerSubmit(_ quitQuizController: QuitQuizController)
}

class QuitQuizController: UIViewController {
    
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var submitButton: UIButton!
    
    private let alertTransitioningDelegate = AlertTransitioningDelegate()
    override var transitioningDelegate: UIViewControllerTransitioningDelegate? {
        get {
            return alertTransitioningDelegate
        }
        set { }
    }
    override var modalPresentationStyle: UIModalPresentationStyle {
        get {
            return .custom
        }
        set { }
    }
    
    var answeredQuestionCount = 0
    
    weak var delegate: QuitQuizControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subtitleLabel.text = "You’ve answered \(answeredQuestionCount) question\(answeredQuestionCount == 1 ? "" : "s") but you still have more time."
        submitButton.setTitle("Submit \(answeredQuestionCount) question\(answeredQuestionCount == 1 ? "" : "s")", for: .normal)
    }
    
    @IBAction private func continueClicked(_ sender: Any) {
        dismiss(animated: true)
        delegate?.quitQuizControllerContinue(self)
    }
    
    @IBAction private func quitClicked(_ sender: Any) {
        dismiss(animated: true)
        delegate?.quitQuizControllerQuit(self)
    }
    
    @IBAction private func submitClicked(_ sender: Any) {
        dismiss(animated: true)
        delegate?.quitQuizControllerSubmit(self)
    }
    
}
