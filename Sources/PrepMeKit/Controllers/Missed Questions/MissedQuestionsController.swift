import UIKit

class MissedQuestionsController: UIViewController {
    
    @IBOutlet private weak var incorrectView: UIView!
    @IBOutlet private weak var incorrectCountLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var countLabel: UILabel!
    @IBOutlet private weak var sliderStackView: UIStackView!
    @IBOutlet private weak var slider: UISlider!
    @IBOutlet private weak var maxSliderValueLabel: UILabel!
    @IBOutlet private weak var continueButton: UIButton!
    
    var questions = [Question]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        incorrectView.backgroundColor = UIColor(hex: questions.isEmpty ? 0xD7EDE8 : 0xFFE5E5)
        incorrectCountLabel.text = String(questions.count)
        subtitleLabel.text = questions.isEmpty ? "You have no wrong answers, congratulations!" : "How many questions?"
        sliderStackView.isHidden = questions.isEmpty
        slider.maximumValue = Float(questions.count)
        slider.value = Float(min(10, questions.count))
        countLabel.text = String(Int(slider.value))
        countLabel.isHidden = questions.isEmpty
        maxSliderValueLabel.text = String(questions.count)
        continueButton.setTitle(questions.isEmpty ? "Close" : "Start Quiz", for: .normal)
    }
    
    @IBAction private func closeClicked(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction private func timeChanged(_ sender: Any) {
        countLabel.text = String(Int(slider.value))
    }
    
    @IBAction private func continueClicked(_ sender: Any) {
        dismiss(animated: true)
        
        if !questions.isEmpty {
            let quizController = QuizController.instantiate(bundle: .module)
            quizController.questions = Array(questions.shuffled().prefix(Int(slider.value)))
            quizController.quizMode = .mistakesQuiz
            presentingViewController?.present(quizController, animated: true)
        }
    }
    
}
