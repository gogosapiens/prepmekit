import UIKit

class QuizController: UIViewController {
    
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var contentStackView: UIStackView!
    @IBOutlet private weak var paginationView: PaginationView!
    @IBOutlet private weak var timerView: UIView!
    @IBOutlet private weak var timerLabel: UILabel!
    @IBOutlet private weak var reviewQuestionCounterLabel: UILabel!
    @IBOutlet private weak var questionCounterLabel: UILabel!
    @IBOutlet private weak var mainScrollView: UIScrollView!
    @IBOutlet private weak var questionWebView: WebView!
    @IBOutlet private weak var answersStackView: UIStackView!
    @IBOutlet private weak var previousButton: QuizNavigationButton!
    @IBOutlet private weak var nextButton: QuizNavigationButton!
    @IBOutlet private weak var submitButton: UIButton!
    
    private let startDate = Date.now
    private var timer: Timer?
    private var isTimerFinished: Bool {
        return timer?.isValid == false
    }
    
    var currentQuestionIndex = 0
    var selectedChoiceIds = [Question.ID: Set<Choice.ID>]()
    var confirmedQuestionIds = Set<Question.ID>()
    var questions = [Question]()
    var quizMode: QuizMode = .quickTenQuiz
    var remainingSeconds = 600
    var isReview = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentStackView.setCustomSpacing(24, after: paginationView)
        contentStackView.setCustomSpacing(12, after: reviewQuestionCounterLabel)
        
        isModalInPresentation = true
        
        closeButton.setImage(UIImage(resource: isReview ? .chevronLeft : .close), for: .normal)
        titleLabel.text = isReview ? "Review correct" : quizMode.title
        paginationView.isHidden = true
        timerView.isHidden = true
        reviewQuestionCounterLabel.isHidden = !isReview
        questionWebView.setFont(size: 16, weight: .semibold)
        
        switch quizMode {
        case .quickTenQuiz, .toughTopicQuiz, .mistakesQuiz, .buildOwnQuiz:
            if !isReview {
                paginationView.isHidden = false
                paginationView.setup(numberOfPages: questions.count)
            }
        case .timedQuiz, .mockExam:
            timerView.isHidden = false
            timer = .scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                self?.updateTimer()
            }
            if let timer {
                RunLoop.main.add(timer, forMode: .common)
            }
            timer?.fire()
        default:
            break
        }
        
        for index in 0..<questions.count {
            questions[index].choices.shuffle()
        }
        
        setupQuestion(questions[currentQuestionIndex])
    }
    
    private func updateTimer() {
        remainingSeconds -= 1
        let hours = remainingSeconds / 3600
        let minutes = remainingSeconds / 60 % 60
        let seconds = remainingSeconds % 60
        var timeComponents = [
            "\(seconds < 10 ? "0" : "")\(seconds)",
            "\(minutes < 10 ? "0" : "")\(minutes)"
        ]
        if hours > 0 {
            timeComponents.append("\(hours < 10 ? "0" : "")\(hours)")
        }
        timerLabel.text = timeComponents.reversed().joined(separator: ":")
        if remainingSeconds == 0 {
            timerLabel.textColor = UIColor(resource: .wrong)
            timer?.invalidate()
            updateNavigationButtons()
        } else if remainingSeconds <= 300 {
            timerLabel.textColor = UIColor(hex: 0xFF8F0F)
        }
    }
    
    private func setupQuestion(_ question: Question) {
        switch quizMode {
        case .questionOfTheDay:
            questionCounterLabel.text = Date.now.formatted(date: .long, time: .omitted)
        case .quickTenQuiz, .toughTopicQuiz, .mistakesQuiz, .buildOwnQuiz:
            paginationView.setCurrentIndex(currentQuestionIndex)
            reviewQuestionCounterLabel.text = "\(currentQuestionIndex + 1)/\(questions.count)"
            if isReview {
                questionCounterLabel.text = question.subject.name.uppercased()
            } else {
                questionCounterLabel.text = "QUESTION \(currentQuestionIndex + 1)/\(questions.count)"
            }
        case .timedQuiz:
            questionCounterLabel.text = "QUESTION \(currentQuestionIndex + 1)"
        case .mockExam:
            questionCounterLabel.text = "QUESTION \(currentQuestionIndex + 1)/\(questions.count)"
        }
        questionWebView.setContent(question.prompt)
        reloadAnswers(question: question)
        mainScrollView.contentOffset = .zero
        updateNavigationButtons()
    }
    
    private func reloadAnswers(question: Question) {
        let isQuestionConfirmed = confirmedQuestionIds.contains(question.objectId)
        
        for (index, choice) in question.choices.enumerated() {
            let choiceView = (answersStackView.arrangedSubviews[safe: index] as? ChoiceView) ?? .instantiate()
            choiceView.setup(with: choice, explanation: question.explanation, reference: question.references.joined(separator: "\n"))
            choiceView.delegate = self
            
            if isQuestionConfirmed && choice.isCorrect {
                if question.isMultipleCorrectChoice {
                    choiceView.selectMissedCorrect()
                } else {
                    choiceView.selectCorrect()
                    choiceView.showCollapseButton()
                }
            }
            
            if selectedChoiceIds[question.objectId]?.contains(choice.id) == true {
                if isQuestionConfirmed {
                    if choice.isCorrect {
                        choiceView.selectCorrect()
                        if !question.isMultipleCorrectChoice {
                            choiceView.showCollapseButton()
                        }
                    } else {
                        choiceView.selectWrong()
                    }
                } else {
                    choiceView.select()
                }
            }
            
            if choiceView.superview == nil {
                answersStackView.addArrangedSubview(choiceView)
            }
        }
        
        var choiceViewCount = question.choices.count
        
        if isQuestionConfirmed && question.isMultipleCorrectChoice {
            addExplanationView()
            choiceViewCount += 1
        }
        
        answersStackView.arrangedSubviews.dropFirst(choiceViewCount).forEach { $0.removeFromSuperview() }
    }
    
    private func getChoiceView(at index: Int) -> ChoiceView? {
        return answersStackView.arrangedSubviews[safe: index] as? ChoiceView
    }
    
    private func updateNavigationButtons() {
        let question = questions[currentQuestionIndex]
        let hasSelection = selectedChoiceIds[question.objectId]?.isEmpty == false
        let isConfirmedSelection = confirmedQuestionIds.contains(question.objectId)
        previousButton.isEnabled = currentQuestionIndex > 0
        nextButton.isActive = hasSelection
        nextButton.isHidden = currentQuestionIndex >= questions.count - 1
        submitButton.backgroundColor = hasSelection ? .prepMeAccent : .scepShade2
        submitButton.isUserInteractionEnabled = hasSelection
        submitButton.isHidden = currentQuestionIndex < questions.count - 1
        submitButton.setTitle(isConfirmedSelection && quizMode == .questionOfTheDay || isReview ? "Close" : "Submit", for: .normal)
        
        if isTimerFinished {
            previousButton.isEnabled = false
            nextButton.isHidden = true
            submitButton.isHidden = false
        }
    }
    
    private func confirmSelection() {
        let question = questions[currentQuestionIndex]
        confirmedQuestionIds.insert(question.objectId)
        
        let correctChoiceIndexes = question.choices.enumerated().filter { _, choice in
            return choice.isCorrect
        }.map(\.offset)
        for index in correctChoiceIndexes {
            let choiceView = getChoiceView(at: index)
            
            if question.isMultipleCorrectChoice {
                choiceView?.selectMissedCorrect()
            } else {
                choiceView?.selectCorrect()
                choiceView?.showCollapseButton()
            }
        }
        
        let selectedChoiceIndexes = question.choices.enumerated().filter { _, choice in
            return selectedChoiceIds[question.objectId]?.contains(choice.id) == true
        }.map(\.offset)
        for index in selectedChoiceIndexes {
            let choiceView = getChoiceView(at: index)
            
            if question.choices[index].isCorrect {
                choiceView?.selectCorrect()
                if !question.isMultipleCorrectChoice {
                    choiceView?.showCollapseButton()
                }
            } else {
                choiceView?.selectWrong()
            }
        }
        
        if question.isMultipleCorrectChoice {
            addExplanationView()
        }
        
        updateNavigationButtons()
    }
    
    private func addExplanationView() {
        let question = questions[currentQuestionIndex]
        let selectedChoices = selectedChoiceIds[question.objectId, default: []]
            .compactMap(question.choices.first)
        let correctChoiceCount = selectedChoices.count(where: \.isCorrect)
        let containsWrongChoice = selectedChoices.contains(where: { !$0.isCorrect })
        let isCorrectAnswer = correctChoiceCount == question.correctChoiceCount && !containsWrongChoice
        let choiceView = (answersStackView.arrangedSubviews[safe: question.choices.count] as? ChoiceView) ?? .instantiate()
        choiceView.setup(
            with: isCorrectAnswer ? "Correct" : "Incorrect",
            explanation: question.explanation,
            reference: question.references.joined(separator: "\n")
        )
        choiceView.showCollapseButton()
        choiceView.delegate = nil
        if choiceView.superview == nil {
            answersStackView.addArrangedSubview(choiceView)
        }
    }
    
    @IBAction private func closeClicked(_ sender: Any) {
        if isReview {
            navigationController?.popViewController(animated: true)
        } else if confirmedQuestionIds.isEmpty {
            dismiss(animated: true)
        } else {
            let quitQuizController = QuitQuizController.instantiate(bundle: .module)
            quitQuizController.answeredQuestionCount = confirmedQuestionIds.count
            quitQuizController.delegate = self
            present(quitQuizController, animated: true)
        }
    }
    
    @IBAction private func previousQuestionClicked(_ sender: Any) {
        currentQuestionIndex -= 1
        questions[safe: currentQuestionIndex].map(setupQuestion)
    }
    
    @IBAction private func nextQuestionClicked(_ sender: Any) {
        let question = questions[currentQuestionIndex]
        if confirmedQuestionIds.contains(question.objectId) || selectedChoiceIds[question.objectId] == nil {
            currentQuestionIndex += 1
            if isTimerFinished {
                submitQuiz()
            } else if let question = questions[safe: currentQuestionIndex] {
                setupQuestion(question)
            } else if isReview {
                navigationController?.popViewController(animated: true)
            } else {
                submitQuiz()
            }
        } else {
            confirmSelection()
        }
    }
    
    private func submitQuiz() {
        timer?.invalidate()
        
        let confirmedQuestion = confirmedQuestionIds.compactMap(questions.first)
        let selectedChoiceIds = self.selectedChoiceIds.filter { questionId, _ in
            return confirmedQuestionIds.contains(questionId)
        }
        
        let quizResult = QuizResult(
            mode: quizMode,
            date: .now,
            questions: confirmedQuestion,
            selectedChoiceIds: selectedChoiceIds,
            duration: Int(Date.now.timeIntervalSince(startDate)),
            communityScore: 67
        )
        ResultStorage.shared.save(quizResult: quizResult)
        
        if quizMode == .questionOfTheDay {
            dismiss(animated: true)
        } else {
            let quizResultController = QuizResultController.instantiate(bundle: .module)
            quizResultController.quizResult = quizResult
            let navigationController = NavigationController(rootViewController: quizResultController)
            present(navigationController, animated: true)
        }
    }
    
    deinit {
        timer?.invalidate()
    }
    
}

extension QuizController: ChoiceViewDelegate {
    
    func choiceViewDidSelect(_ choiceView: ChoiceView) {
        guard let index = answersStackView.arrangedSubviews.firstIndex(of: choiceView) else { return }
        
        let question = questions[currentQuestionIndex]
        guard !confirmedQuestionIds.contains(question.objectId) else { return }
        
        let choice = question.choices[index]
        
        if question.isMultipleCorrectChoice {
            if selectedChoiceIds[question.objectId, default: []].contains(choice.id) {
                choiceView.deselect()
                
                selectedChoiceIds[question.objectId, default: []].remove(choice.id)
            } else {
                choiceView.select()
                
                selectedChoiceIds[question.objectId, default: []].insert(choice.id)
            }
        } else {
            let selectedChoiceIndexes = question.choices.enumerated().filter { _, choice in
                return selectedChoiceIds[question.objectId]?.contains(choice.id) == true
            }.map(\.offset)
            
            for selectedChoiceIndex in selectedChoiceIndexes {
                getChoiceView(at: selectedChoiceIndex)?.deselect()
            }
            
            choiceView.select()
            
            selectedChoiceIds[question.objectId] = [choice.id]
        }
        
        UISelectionFeedbackGenerator().selectionChanged()
        
        if quizMode == .questionOfTheDay || question.isMultipleCorrectChoice {
            updateNavigationButtons()
        } else {
            confirmSelection()
        }
    }
    
}

extension QuizController: QuitQuizControllerDelegate {
    
    func quitQuizControllerContinue(_ quitQuizController: QuitQuizController) {
        
    }
    
    func quitQuizControllerQuit(_ quitQuizController: QuitQuizController) {
        dismiss(animated: true)
    }
    
    func quitQuizControllerSubmit(_ quitQuizController: QuitQuizController) {
        submitQuiz()
    }
    
}
