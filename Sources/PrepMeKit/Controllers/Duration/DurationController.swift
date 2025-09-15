import UIKit

class DurationController: UIViewController {
    
    @IBOutlet private weak var timeLabel: UILabel!
    @IBOutlet private weak var slider: UISlider!
    
    var questions = [Question]()
    
    @IBAction private func closeClicked(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction private func timeChanged(_ sender: Any) {
        timeLabel.text = String(Int(slider.value))
    }
    
    @IBAction private func startClicked(_ sender: Any) {
        dismiss(animated: true)
        
        let quizController = QuizController.instantiate(bundle: .module)
        quizController.questions = questions
        quizController.quizMode = .timedQuiz
        quizController.remainingSeconds = Int(slider.value) * 60
        presentingViewController?.present(quizController, animated: true)
    }
    
}
