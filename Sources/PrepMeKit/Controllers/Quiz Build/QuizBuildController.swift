import UIKit

class QuizBuildController: UIViewController {
    
    private enum Filter: CaseIterable {
        case newQuestions
        case answeredQuestions
        case incorrectQuestions
    }
    
    @IBOutlet private weak var subjectsLabel: UILabel!
    @IBOutlet private weak var filterView: UIView!
    @IBOutlet private weak var newQuestionCountLabel: UILabel!
    @IBOutlet private weak var newQuestionsCheckboxImageView: UIImageView!
    @IBOutlet private weak var answeredQuestionCountLabel: UILabel!
    @IBOutlet private weak var answeredQuestionsCheckboxImageView: UIImageView!
    @IBOutlet private weak var incorrectQuestionCountLabel: UILabel!
    @IBOutlet private weak var incorrectQuestionsCheckboxImageView: UIImageView!
    @IBOutlet private weak var questionCountLabel: UILabel!
    @IBOutlet private weak var slider: UISlider!
    @IBOutlet private weak var sliderMinValueLabel: UILabel!
    @IBOutlet private weak var sliderMaxValueLabel: UILabel!
    @IBOutlet private weak var startButton: UIButton!
    
    private var includeFilters = Set<Filter>(Filter.allCases)
    private var newQuestions = Set<Question>()
    private var answeredQuestions = Set<Question>()
    private var incorrectQuestions = Set<Question>()
    
    private var questions: Set<Question> {
        var questions = Set<Question>()
        if includeFilters.contains(.newQuestions) {
            questions.formUnion(newQuestions)
        }
        if includeFilters.contains(.answeredQuestions) {
            questions.formUnion(answeredQuestions)
        }
        if includeFilters.contains(.incorrectQuestions) {
            questions.formUnion(incorrectQuestions)
        }
        return questions
    }
    
    var selectedSubjectIds = Set<Subject.ID>()
    var exam: Exam!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filterView.layer.borderWidth = 1
        filterView.layer.borderColor = UIColor.scepShade2.cgColor
        
        reloadData()
    }
    
    private func reloadData() {
        subjectsLabel.text = selectedSubjectIds.count >= exam.subjects.count ? "All subjects" : "\(selectedSubjectIds.count) subject\(selectedSubjectIds.count == 1 ? "" : "s")"
        
        let allQuestions = Set(ExamStorage.shared.questions[exam.id] ?? [])
        let oldQuestions = Set(ResultStorage.shared.quizResults.flatMap(\.questions))
        
        newQuestions = allQuestions.subtracting(oldQuestions).filter({ selectedSubjectIds.contains($0.subject.id) })
        newQuestionCountLabel.text = String(newQuestions.count)
        newQuestionCountLabel.textColor = includeFilters.contains(.newQuestions) ? .scepShade1 : .scepShade2
        newQuestionsCheckboxImageView.image = UIImage(resource: includeFilters.contains(.newQuestions) ? .checkboxChecked : .checkboxUnchecked)
        
        answeredQuestions = oldQuestions.filter({ selectedSubjectIds.contains($0.subject.id) })
        answeredQuestionCountLabel.text = String(answeredQuestions.count)
        answeredQuestionCountLabel.textColor = includeFilters.contains(.answeredQuestions) ? .scepShade1 : .scepShade2
        answeredQuestionsCheckboxImageView.image = UIImage(resource: includeFilters.contains(.answeredQuestions) ? .checkboxChecked : .checkboxUnchecked)
        
        incorrectQuestions = Set(ResultStorage.shared.quizResults.flatMap(\.wrongAnsweredQuestions)).filter({ selectedSubjectIds.contains($0.subject.id) })
        incorrectQuestionCountLabel.text = String(incorrectQuestions.count)
        incorrectQuestionCountLabel.textColor = includeFilters.contains(.incorrectQuestions) ? .scepShade1 : .scepShade2
        incorrectQuestionsCheckboxImageView.image = UIImage(resource: includeFilters.contains(.incorrectQuestions) ? .checkboxChecked : .checkboxUnchecked)
        
        let minValue = min(1, questions.count)
        slider.minimumValue = Float(minValue)
        slider.maximumValue = Float(questions.count)
        slider.value = Float(min(Int(slider.value), questions.count))
        questionCountLabel.text = String(Int(slider.value))
        sliderMinValueLabel.text = String(minValue)
        sliderMaxValueLabel.text = String(questions.count)
        
        let isStartEnabled = !questions.isEmpty
        startButton.backgroundColor = isStartEnabled ? .scepAccent : .scepShade2
        startButton.isUserInteractionEnabled = isStartEnabled
    }
    
    @IBAction private func closeClicked(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction private func subjectsClicked(_ sender: Any) {
        let subjectsController = SubjectsController.instantiate(bundle: .module)
        subjectsController.exam = exam
        subjectsController.selectedSubjectIds = selectedSubjectIds
        subjectsController.delegate = self
        present(subjectsController, animated: true)
    }
    
    @IBAction private func newQuestionsFilterClicked(_ sender: Any) {
        if includeFilters.contains(.newQuestions) {
            includeFilters.remove(.newQuestions)
        } else {
            includeFilters.insert(.newQuestions)
        }
        reloadData()
    }
    
    @IBAction private func answeredQuestionsFilterClicked(_ sender: Any) {
        if includeFilters.contains(.answeredQuestions) {
            includeFilters.remove(.answeredQuestions)
        } else {
            includeFilters.insert(.answeredQuestions)
        }
        reloadData()
    }
    
    @IBAction private func incorrectQuestionsFilterClicked(_ sender: Any) {
        if includeFilters.contains(.incorrectQuestions) {
            includeFilters.remove(.incorrectQuestions)
        } else {
            includeFilters.insert(.incorrectQuestions)
        }
        reloadData()
    }
    
    @IBAction private func sliderValueChanged(_ sender: Any) {
        questionCountLabel.text = String(Int(slider.value))
    }
    
    @IBAction private func startClicked(_ sender: Any) {
        dismiss(animated: true)
        
        let quizController = QuizController.instantiate(bundle: .module)
        quizController.questions = Array(questions.shuffled().prefix(Int(slider.value)))
        quizController.quizMode = .buildOwnQuiz
        presentingViewController?.present(quizController, animated: true)
    }
    
}

extension QuizBuildController: SubjectsControllerDelegate {
    
    func subjectsController(
        _ subjectsController: SubjectsController,
        didSelect subjectIds: Set<String>
    ) {
        selectedSubjectIds = subjectIds
        reloadData()
    }
    
}
