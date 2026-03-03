import UIKit

class QuizController: UIViewController {
    
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var questionStackView: UIStackView!
    @IBOutlet private weak var paginationView: PaginationView!
    @IBOutlet private weak var timerView: UIView!
    @IBOutlet private weak var timerLabel: UILabel!
    @IBOutlet private weak var reviewQuestionCounterLabel: UILabel!
    @IBOutlet private weak var questionCounterLabel: UILabel!
    @IBOutlet private weak var mainScrollView: UIScrollView!
    @IBOutlet private weak var questionWebView: WebView!
    @IBOutlet private weak var contentStackView: UIStackView!
    @IBOutlet private weak var subquestionsStackView: UIStackView!
    @IBOutlet private weak var answersStackView: UIStackView!
    @IBOutlet private weak var previousButton: QuizNavigationButton!
    @IBOutlet private weak var nextButton: QuizNavigationButton!
    @IBOutlet private weak var submitButton: UIButton!
    
    private let passageView = PassageView.instantiate()
    private let startDate = Date.now
    private var timer: Timer?
    private var isTimerFinished: Bool {
        return timer?.isValid == false
    }
    
    var currentQuestionIndex = 0
    var selectedChoiceIds = [Question.ID: [Choice.ID]]()
    var selectedSubquestionAnswerIndexes = [Question.ID: [Set<Int>]]()
    var confirmedQuestionIds = Set<Question.ID>()
    var questions = [Question]()
    var quizMode: QuizMode = .quickTenQuiz
    var remainingSeconds = 600
    var isReview = false
    var customTitle: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        questionStackView.setCustomSpacing(24, after: paginationView)
        questionStackView.setCustomSpacing(12, after: reviewQuestionCounterLabel)
        
        contentStackView.insertArrangedSubview(passageView, at: 0)
        
        isModalInPresentation = true
        
        closeButton.setImage(UIImage(resource: isReview ? .chevronLeft : .close), for: .normal)
        titleLabel.text = customTitle ?? quizMode.title
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
        
        if !isReview {
            for index in 0..<questions.count {
                questions[index].choices.shuffle()
            }
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
        if question.type == .buildList && selectedChoiceIds[question.objectId] == nil {
            selectedChoiceIds[question.objectId] = question.choices.map(\.id)
        }
        questionWebView.setContent(question.prompt)
        setupPassage(question: question)
        reloadSubquestions(question: question)
        reloadAnswers(question: question)
        mainScrollView.contentOffset = .zero
        updateNavigationButtons()
    }
    
    private func setupPassage(question: Question) {
        if question.passage?.isEmpty != false && question.passageLabel?.isEmpty != false && question.passageImage == nil {
            passageView.isHidden = true
        } else {
            passageView.setup(
                passage: question.passage,
                passageLabel: question.passageLabel,
                passageImage: question.passageImage
            )
            passageView.isHidden = false
        }
    }
    
    private func reloadSubquestions(question: Question) {
        subquestionsStackView.isHidden = !question.hasSubquestions
        guard question.hasSubquestions else { return }
        let isQuestionConfirmed = confirmedQuestionIds.contains(question.objectId)
        let selectedSubquestionAnswerIndexes = self.selectedSubquestionAnswerIndexes[question.objectId] ?? []
        let subquestions = question.subquestions
        
        for (subquestionIndex, row) in subquestions.enumerated() {
            let answers = question.getAnswers(subquestionIndex: subquestionIndex)
            
            let subquestionView = (subquestionsStackView.arrangedSubviews[safe: subquestionIndex] as? SubquestionView) ?? .instantiate()
            subquestionView.setup(
                with: row,
                answers: answers,
                isMultipleCorrectAnswer: question.type == .matrixCheckbox || question.type == .multiPartMultipleChoice
            )
            subquestionView.delegate = self
            
            let selectedAnswerIndexes = selectedSubquestionAnswerIndexes[safe: subquestionIndex] ?? []
            for subquestionAnswerIndex in 0..<answers.count {
                if isQuestionConfirmed {
                    if question.isCorrect(subquestionIndex: subquestionIndex, answerIndex: subquestionAnswerIndex) {
                        if question.type == .matrixCheckbox || question.type == .matrixRadioButton || question.type == .multiPartMultipleChoice {
                            subquestionView.selectMissedCorrectAnswer(index: subquestionAnswerIndex)
                        } else {
                            subquestionView.selectCorrectAnswer(index: subquestionAnswerIndex)
                        }
                    } else {
                        subquestionView.crossOutAnswer(index: subquestionAnswerIndex)
                    }
                }
                
                if selectedAnswerIndexes.contains(subquestionAnswerIndex) {
                    if isQuestionConfirmed {
                        if question.isCorrect(subquestionIndex: subquestionIndex, answerIndex: subquestionAnswerIndex) {
                            subquestionView.selectCorrectAnswer(index: subquestionAnswerIndex)
                        } else {
                            subquestionView.selectWrongAnswer(index: subquestionAnswerIndex)
                        }
                    } else {
                        subquestionView.selectAnswer(index: subquestionAnswerIndex)
                    }
                }
            }
            
            if isQuestionConfirmed {
                if selectedAnswerIndexes == question.getCorrectAnswerIndexes(subquestionIndex: subquestionIndex) {
                    subquestionView.selectCorrect()
                } else {
                    subquestionView.selectWrong()
                }
            }
            
            if subquestionView.superview == nil {
                subquestionsStackView.addArrangedSubview(subquestionView)
            }
        }
        
        subquestionsStackView.arrangedSubviews.dropFirst(subquestions.count).forEach { $0.removeFromSuperview() }
    }
    
    private func reloadAnswers(question: Question) {
        let isQuestionConfirmed = confirmedQuestionIds.contains(question.objectId)
        
        if !question.hasSubquestions {
            let correctChoiceIds = question.correctChoiceIds
            
            for (index, choice) in question.choices.enumerated() {
                let choiceView = (answersStackView.arrangedSubviews[safe: index] as? ChoiceView) ?? .instantiate()
                choiceView.setup(
                    with: choice,
                    explanation: question.explanation,
                    reference: question.references.joined(separator: "\n"),
                    questionType: question.type,
                    explanationImage: question.explanationImage
                )
                choiceView.delegate = self
                
                if question.type == .buildList {
                    choiceView.setIndex(index, of: question.choices.count)
                    if isQuestionConfirmed {
                        guard let correctIndex = correctChoiceIds.firstIndex(of: choice.id) else { continue }
                        
                        if index == correctIndex {
                            choiceView.selectCorrect()
                        } else {
                            choiceView.selectWrong()
                            choiceView.setTrailingIndex(correctIndex)
                        }
                    }
                } else {
                    if isQuestionConfirmed && choice.isCorrect {
                        if question.type == .multipleCorrectResponse {
                            choiceView.selectMissedCorrect()
                        } else {
                            choiceView.selectCorrect()
                            if !isShowSeparateExplanation(question: question) {
                                choiceView.showCollapseButton()
                            }
                        }
                    }
                    
                    if selectedChoiceIds[question.objectId]?.contains(choice.id) == true {
                        if isQuestionConfirmed {
                            if choice.isCorrect {
                                choiceView.selectCorrect()
                                if !isShowSeparateExplanation(question: question) {
                                    choiceView.showCollapseButton()
                                }
                            } else {
                                choiceView.selectWrong()
                            }
                            
                            if question.type == .trueFalse {
                                choiceView.select()
                            }
                        } else {
                            choiceView.select()
                        }
                    }
                }
                
                if choiceView.superview == nil {
                    answersStackView.addArrangedSubview(choiceView)
                }
            }
        }
        
        var choiceViewCount = question.hasSubquestions ? 0 : question.choices.count
        
        if isQuestionConfirmed && isShowSeparateExplanation(question: question) {
            addExplanationView()
            choiceViewCount += 1
        }
        
        answersStackView.arrangedSubviews.dropFirst(choiceViewCount).forEach { $0.removeFromSuperview() }
    }
    
    private func getChoiceView(at index: Int) -> ChoiceView? {
        return answersStackView.arrangedSubviews[safe: index] as? ChoiceView
    }
    
    private func getSubquestionView(at index: Int) -> SubquestionView? {
        return subquestionsStackView.arrangedSubviews[safe: index] as? SubquestionView
    }
    
    private func isShowSeparateExplanation(question: Question) -> Bool {
        return question.type == .multipleCorrectResponse ||
        question.type == .matrixCheckbox ||
        question.type == .matrixRadioButton ||
        question.type == .multiPartMultipleChoice ||
        question.type == .buildList
    }
    
    private func isManualConfirmation(question: Question) -> Bool {
        return quizMode == .questionOfTheDay ||
        question.type == .multipleCorrectResponse ||
        question.type == .trueFalse ||
        question.type == .matrixCheckbox ||
        question.type == .matrixRadioButton ||
        question.type == .multiPartMultipleChoice
    }
    
    private func updateNavigationButtons() {
        let question = questions[currentQuestionIndex]
        let hasSelection = selectedChoiceIds[question.objectId]?.isEmpty == false || selectedSubquestionAnswerIndexes[question.objectId]?.flatMap({ $0 }).isEmpty == false
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
        
        switch question.type {
        case .matrixCheckbox, .matrixRadioButton, .multiPartMultipleChoice:
            for subquestionIndex in 0..<question.subquestions.count {
                let subquestionView = getSubquestionView(at: subquestionIndex)
                for subquestionAnswerIndex in 0..<question.getAnswers(subquestionIndex: subquestionIndex).count {
                    if question.isCorrect(subquestionIndex: subquestionIndex, answerIndex: subquestionAnswerIndex) {
                        if question.type == .matrixCheckbox || question.type == .matrixRadioButton || question.type == .multiPartMultipleChoice {
                            subquestionView?.selectMissedCorrectAnswer(index: subquestionAnswerIndex)
                        } else {
                            subquestionView?.selectCorrectAnswer(index: subquestionAnswerIndex)
                        }
                    } else {
                        subquestionView?.crossOutAnswer(index: subquestionAnswerIndex)
                    }
                }
            }
            
            let selectedSubquestionAnswerIndexes = self.selectedSubquestionAnswerIndexes[question.objectId] ?? []
            for (subquestionIndex, subquestionAnswerIndexes) in selectedSubquestionAnswerIndexes.enumerated() {
                let subquestionView = getSubquestionView(at: subquestionIndex)
                for subquestionAnswerIndex in subquestionAnswerIndexes {
                    if question.isCorrect(subquestionIndex: subquestionIndex, answerIndex: subquestionAnswerIndex) {
                        subquestionView?.selectCorrectAnswer(index: subquestionAnswerIndex)
                    } else {
                        subquestionView?.selectWrongAnswer(index: subquestionAnswerIndex)
                    }
                }
                
                if subquestionAnswerIndexes == question.getCorrectAnswerIndexes(subquestionIndex: subquestionIndex) {
                    subquestionView?.selectCorrect()
                } else {
                    subquestionView?.selectWrong()
                }
            }
            
        case .buildList:
            let correctChoiceIds = question.correctChoiceIds
            for (index, choiceId) in selectedChoiceIds[question.objectId, default: []].enumerated() {
                let choiceView = getChoiceView(at: index)
                
                guard let correctIndex = correctChoiceIds.firstIndex(of: choiceId) else { continue }
                
                if index == correctIndex {
                    choiceView?.selectCorrect()
                } else {
                    choiceView?.selectWrong()
                    choiceView?.setTrailingIndex(correctIndex)
                }
            }
            
        default:
            let correctChoiceIndexes = question.choices.enumerated().filter { _, choice in
                return choice.isCorrect
            }.map(\.offset)
            for index in correctChoiceIndexes {
                let choiceView = getChoiceView(at: index)
                
                if question.type == .multipleCorrectResponse {
                    choiceView?.selectMissedCorrect()
                } else {
                    choiceView?.selectCorrect()
                    if !isShowSeparateExplanation(question: question) {
                        choiceView?.showCollapseButton()
                    }
                }
            }
            
            let selectedChoiceIndexes = question.choices.enumerated().filter { _, choice in
                return selectedChoiceIds[question.objectId]?.contains(choice.id) == true
            }.map(\.offset)
            for index in selectedChoiceIndexes {
                let choiceView = getChoiceView(at: index)
                
                if question.choices[index].isCorrect {
                    choiceView?.selectCorrect()
                    if !isShowSeparateExplanation(question: question) {
                        choiceView?.showCollapseButton()
                    }
                } else {
                    choiceView?.selectWrong()
                }
            }
        }
        
        if isShowSeparateExplanation(question: question) {
            addExplanationView { [weak self] in
                self?.scrollToBottom()
            }
        }
        
        updateNavigationButtons()
    }
    
    private func addExplanationView(completion: (() -> ())? = nil) {
        let question = questions[currentQuestionIndex]
        let isCorrectAnswer = question.hasSubquestions ? selectedSubquestionAnswerIndexes[question.objectId] == question.correctSubquestionAnswerIndexes : question.type == .buildList ? selectedChoiceIds[question.objectId] == question.correctChoiceIds : selectedChoiceIds[question.objectId].map(Set.init) == Set(question.correctChoiceIds)
        let choiceView = (answersStackView.arrangedSubviews[safe: question.hasSubquestions ? 0 : question.choices.count] as? ChoiceView) ?? .instantiate()
        choiceView.setup(
            with: isCorrectAnswer ? "Correct" : "Incorrect",
            explanation: question.explanation,
            reference: question.references.joined(separator: "\n"),
            questionType: nil,
            explanationImage: question.explanationImage,
            completion: completion
        )
        choiceView.showCollapseButton()
        choiceView.delegate = nil
        if choiceView.superview == nil {
            answersStackView.addArrangedSubview(choiceView)
        }
    }
    
    private func scrollToBottom() {
        view.layoutIfNeeded()
        mainScrollView.setContentOffset(
            CGPoint(x: 0, y: max(0, mainScrollView.contentSize.height - mainScrollView.bounds.size.height)),
            animated: true
        )
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
        let isQuestionConfirmed = confirmedQuestionIds.contains(question.objectId)
        let hasSelection = selectedChoiceIds[question.objectId]?.isEmpty == false || selectedSubquestionAnswerIndexes[question.objectId]?.flatMap({ $0 }).isEmpty == false
        if isQuestionConfirmed || !hasSelection {
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
        let selectedSubquestionAnswerIndexes = self.selectedSubquestionAnswerIndexes.filter { questionId, _ in
            return confirmedQuestionIds.contains(questionId)
        }
        
        let quizResult = QuizResult(
            mode: quizMode,
            date: .now,
            questions: confirmedQuestion,
            selectedChoiceIds: selectedChoiceIds,
            selectedSubquestionAnswerIndexes: selectedSubquestionAnswerIndexes,
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
        
        if question.type == .multipleCorrectResponse {
            if let index = selectedChoiceIds[question.objectId]?.firstIndex(of: choice.id) {
                choiceView.deselect()
                
                selectedChoiceIds[question.objectId]?.remove(at: index)
            } else {
                choiceView.select()
                
                selectedChoiceIds[question.objectId, default: []].append(choice.id)
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
        
        if isManualConfirmation(question: question) {
            updateNavigationButtons()
        } else {
            confirmSelection()
        }
    }
    
    func choiceViewUpOrder(_ choiceView: ChoiceView) {
        guard let index = answersStackView.arrangedSubviews.firstIndex(of: choiceView) else { return }
        
        let question = questions[currentQuestionIndex]
        
        if let choiceId = selectedChoiceIds[question.objectId]?.remove(at: index) {
            selectedChoiceIds[question.objectId]?.insert(choiceId, at: index - 1)
        }
        
        let choice = questions[currentQuestionIndex].choices.remove(at: index)
        questions[currentQuestionIndex].choices.insert(choice, at: index - 1)
        
        answersStackView.removeArrangedSubview(choiceView)
        answersStackView.insertArrangedSubview(choiceView, at: index - 1)
        
        choiceView.setIndex(index - 1, of: question.choices.count)
        (answersStackView.arrangedSubviews[safe: index] as? ChoiceView)?.setIndex(index, of: question.choices.count)
    }
    
    func choiceViewDownOrder(_ choiceView: ChoiceView) {
        guard let index = answersStackView.arrangedSubviews.firstIndex(of: choiceView) else { return }
        
        let question = questions[currentQuestionIndex]
        
        if let choiceId = selectedChoiceIds[question.objectId]?.remove(at: index) {
            selectedChoiceIds[question.objectId]?.insert(choiceId, at: index + 1)
        }
        
        let choice = questions[currentQuestionIndex].choices.remove(at: index)
        questions[currentQuestionIndex].choices.insert(choice, at: index + 1)
        
        answersStackView.removeArrangedSubview(choiceView)
        answersStackView.insertArrangedSubview(choiceView, at: index + 1)
        
        choiceView.setIndex(index + 1, of: question.choices.count)
        (answersStackView.arrangedSubviews[safe: index] as? ChoiceView)?.setIndex(index, of: question.choices.count)
    }
    
}

extension QuizController: SubquestionViewDelegate {
    
    func subquestionView(_ subquestionView: SubquestionView, didSelect answerIndex: Int) {
        guard let subquestionIndex = subquestionsStackView.arrangedSubviews.firstIndex(of: subquestionView) else { return }
        
        let question = questions[currentQuestionIndex]
        guard !confirmedQuestionIds.contains(question.objectId) else { return }
        
        if selectedSubquestionAnswerIndexes[question.objectId] == nil {
            selectedSubquestionAnswerIndexes[question.objectId] = .init(repeating: [], count: question.subquestions.count)
        }
        let subquestionAnswerIndexes = selectedSubquestionAnswerIndexes[question.objectId]?[subquestionIndex] ?? []
        
        switch question.type {
        case .matrixCheckbox, .multiPartMultipleChoice:
            if subquestionAnswerIndexes.contains(answerIndex) {
                subquestionView.deselectAnswer(index: answerIndex)
                
                selectedSubquestionAnswerIndexes[question.objectId]?[subquestionIndex].remove(answerIndex)
            } else {
                subquestionView.selectAnswer(index: answerIndex)
                
                selectedSubquestionAnswerIndexes[question.objectId]?[subquestionIndex].insert(answerIndex)
            }
            
        case .matrixRadioButton:
            for subquestionAnswerIndex in subquestionAnswerIndexes {
                subquestionView.deselectAnswer(index: subquestionAnswerIndex)
            }
            subquestionView.selectAnswer(index: answerIndex)
            selectedSubquestionAnswerIndexes[question.objectId]?[subquestionIndex] = [answerIndex]
            
        default:
            break
        }
        
        UISelectionFeedbackGenerator().selectionChanged()
        
        updateNavigationButtons()
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
