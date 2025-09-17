import UIKit

class QuizController: UIViewController {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var contentStackView: UIStackView!
    @IBOutlet private weak var paginationView: PaginationView!
    @IBOutlet private weak var timerView: UIView!
    @IBOutlet private weak var timerLabel: UILabel!
    @IBOutlet private weak var questionCounterLabel: UILabel!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var answersCollectionView: UICollectionView!
    @IBOutlet private weak var previousButton: QuizNavigationButton!
    @IBOutlet private weak var nextButton: QuizNavigationButton!
    @IBOutlet private weak var submitButton: UIButton!
    
    private let startDate = Date.now
    private var currentQuestionIndex = 0
    private var selectedChoiceIds = [Question.ID: Choice.ID]()
    private var confirmedQuestionIds = Set<Question.ID>()
    private var timer: Timer?
    private var isTimerFinished: Bool {
        return timer?.isValid == false
    }
    private var isExplanationVisible = false
    
    var questions = [Question]()
    var quizMode: QuizMode = .quickTenQuiz
    var remainingSeconds = 600
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentStackView.setCustomSpacing(24, after: paginationView)
        contentStackView.setCustomSpacing(8, after: questionCounterLabel)
        contentStackView.setCustomSpacing(24, after: questionLabel)
        answersCollectionView.register(ChoiceCollectionViewCell.self)
        
        isModalInPresentation = true
        
        titleLabel.text = quizMode.title
        paginationView.isHidden = true
        timerView.isHidden = true
        
        switch quizMode {
        case .quickTenQuiz, .toughTopicQuiz, .mistakesQuiz, .buildOwnQuiz:
            paginationView.isHidden = false
            paginationView.setup(numberOfPages: questions.count)
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
        
        questions.first.map(setupQuestion)
        
        view.layoutIfNeeded()
        if let flowLayout = answersCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = CGSize(
                width: answersCollectionView.bounds.width,
                height: 48
            )
        }
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
            questionCounterLabel.text = "QUESTION \(currentQuestionIndex + 1)/\(questions.count)"
        case .timedQuiz:
            questionCounterLabel.text = "QUESTION \(currentQuestionIndex + 1)"
        case .mockExam:
            questionCounterLabel.text = "QUESTION \(currentQuestionIndex + 1)/\(questions.count)"
        }
        questionLabel.text = question.prompt.removingHTMLTags()
        isExplanationVisible = false
        answersCollectionView.reloadData()
        answersCollectionView.contentOffset = .zero
        updateNavigationButtons()
    }
    
    private func updateNavigationButtons() {
        let question = questions[currentQuestionIndex]
        let hasSelection = selectedChoiceIds[question.objectId] != nil
        let isConfirmedSelection = confirmedQuestionIds.contains(question.objectId)
        previousButton.isEnabled = currentQuestionIndex > 0
        nextButton.isActive = hasSelection
        nextButton.isHidden = currentQuestionIndex >= questions.count - 1
        submitButton.backgroundColor = hasSelection ? .prepMeAccent : .scepShade2
        submitButton.isUserInteractionEnabled = hasSelection
        submitButton.isHidden = currentQuestionIndex < questions.count - 1
        submitButton.setTitle(isConfirmedSelection && quizMode == .questionOfTheDay ? "Close" : "Submit", for: .normal)
        
        if isTimerFinished {
            previousButton.isEnabled = false
            nextButton.isHidden = true
            submitButton.isHidden = false
        }
    }
    
    private func confirmSelection() {
        let question = questions[currentQuestionIndex]
        confirmedQuestionIds.insert(question.objectId)
        guard
            let selectedChoiceId = selectedChoiceIds[question.objectId],
            let selectedChoiceIndex = question.choices.firstIndex(where: { $0.id == selectedChoiceId })
        else {
            return
        }
        
        let indexPath = IndexPath(row: selectedChoiceIndex, section: 0)
        let cell = answersCollectionView.cellForItem(at: indexPath) as? ChoiceCollectionViewCell
        
        if question.choices[selectedChoiceIndex].isCorrect {
            cell?.selectCorrect()
        } else {
            cell?.selectWrong()
            
            if let correctChoiceIndex = question.choices.firstIndex(where: \.isCorrect) {
                let indexPath = IndexPath(row: correctChoiceIndex, section: 0)
                let cell = answersCollectionView.cellForItem(at: indexPath) as? ChoiceCollectionViewCell
                cell?.selectCorrect()
            }
        }
        
        (answersCollectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.invalidateLayout()
        updateNavigationButtons()
    }
    
    @IBAction private func closeClicked(_ sender: Any) {
        if confirmedQuestionIds.isEmpty {
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
            present(quizResultController, animated: true)
        }
    }
    
    deinit {
        timer?.invalidate()
    }
    
}

extension QuizController: UICollectionViewDataSource {
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return questions[currentQuestionIndex].choices.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(of: ChoiceCollectionViewCell.self, for: indexPath)
        let question = questions[currentQuestionIndex]
        let choice = question.choices[indexPath.row]
        cell.setup(with: choice, explanation: question.explanation, reference: question.references.joined(separator: "\n"))
        cell.delegate = self
        if let selectedChoiceId = selectedChoiceIds[question.objectId] {
            if choice.id == selectedChoiceId || choice.isCorrect {
                if !confirmedQuestionIds.contains(question.objectId) {
                    cell.select()
                } else if choice.isCorrect {
                    cell.selectCorrect()
                } else {
                    cell.selectWrong()
                }
            }
        }
        return cell
    }
    
}

extension QuizController: UICollectionViewDelegate {
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        let question = questions[currentQuestionIndex]
        guard !confirmedQuestionIds.contains(question.objectId) else { return }
        
        if let selectedChoiceId = selectedChoiceIds[question.objectId], let selectedChoiceIndex = question.choices.firstIndex(where: { $0.id == selectedChoiceId }) {
            let indexPath = IndexPath(row: selectedChoiceIndex, section: 0)
            let cell = collectionView.cellForItem(at: indexPath) as? ChoiceCollectionViewCell
            cell?.deselect()
        }
        
        let choice = question.choices[indexPath.row]
        selectedChoiceIds[question.objectId] = choice.id
        UISelectionFeedbackGenerator().selectionChanged()
        
        if quizMode == .questionOfTheDay {
            let cell = collectionView.cellForItem(at: indexPath) as? ChoiceCollectionViewCell
            cell?.select()
            updateNavigationButtons()
        } else {
            confirmSelection()
        }
    }
    
}

extension QuizController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = collectionView.bounds.width
        let question = questions[currentQuestionIndex]
        let choice = question.choices[indexPath.row]
        let isQuestionConfirmed = confirmedQuestionIds.contains(question.objectId)
        let isChoiceSelected = selectedChoiceIds[question.objectId] == choice.id
        let height = ChoiceCollectionViewCell.getHeight(
            for: width,
            choice: choice,
            isIndicatorVisible: isQuestionConfirmed ? isChoiceSelected || choice.isCorrect : false,
            isCollapseButtonVisible: isQuestionConfirmed && choice.isCorrect,
            isExplanationVisible: isExplanationVisible && choice.isCorrect,
            explanation: question.explanation,
            reference: question.references.joined(separator: "\n")
        )
        return CGSize(width: width, height: height)
    }
    
}

extension QuizController: ChoiceCollectionViewCellDelegate {
    
    func choiceCollectionViewCellCollapse(_ choiceCollectionViewCell: ChoiceCollectionViewCell) {
        isExplanationVisible.toggle()
        (answersCollectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.invalidateLayout()
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
