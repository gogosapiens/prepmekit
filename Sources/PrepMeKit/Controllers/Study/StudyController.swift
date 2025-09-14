import UIKit
import SCEPKit

class StudyController: UIViewController {
    
    @IBOutlet private weak var navigationBarBackgroundView: UIView!
    @IBOutlet private weak var examButton: UIButton!
    private let header = StudyHeaderView.instantiate()
    @IBOutlet private weak var collectionView: UICollectionView!
    
    private var isQuestionOfTheDayQuizEnabled = true
    private let quizModes = QuizMode.allCases
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Settings.shared.selectedExamId == nil {
            showExams()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.contentInset = .init(top: 202, left: 16, bottom: 16, right: 16)
        collectionView.register(QuestionDayCollectionViewCell.self)
        collectionView.register(QuizModeCollectionViewCell.self)
        
        view.layoutIfNeeded()
        header.frame = .init(x: -16, y: -202, width: collectionView.bounds.width, height: 202)
        header.autoresizingMask = .flexibleWidth
        collectionView.addSubview(header)
        
        reloadData()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: Settings.didChangeSelectedExamNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: ResultStorage.didChangeQuizResultsNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: SCEPKit.premiumUpdatedNotification, object: nil)
    }
    
    @objc private func reloadData() {
        let exam = ExamStorage.shared.getExam(id: Settings.shared.selectedExamId)
        examButton.setTitle(exam?.name ?? "Select exam", for: .normal)
        examButton.setImage(exam == nil ? nil : UIImage(resource: .examSettings), for: .normal)
        
        let calendar = Calendar.current
        let isStreakActive = ResultStorage.shared.quizResults.contains { quizResult in
            return calendar.isDateInToday(quizResult.date)
        }
        let dates = (-4...4).map({ Date(timeIntervalSinceNow: Double($0) * 86_400) })
        header.setup(dates: dates, isStreakActive: isStreakActive, streak: ResultStorage.shared.streak)
        
        isQuestionOfTheDayQuizEnabled = !ResultStorage.shared.quizResults.contains { quizResult in
            return quizResult.mode == .questionOfTheDay && calendar.isDateInToday(quizResult.date)
        }
        collectionView.reloadData()
    }
    
    @IBAction private func settingsClicked(_ sender: Any) {
        SCEPKit.showSettingsController(from: self)
    }
    
    @IBAction private func examSettingsClicked(_ sender: Any) {
        if Settings.shared.selectedExamId == nil {
            showExams()
        } else {
            let examSettingsController = ExamSettingsController.instantiate(bundle: .module)
            let navigationController = NavigationController(rootViewController: examSettingsController)
            navigationController.modalPresentationStyle = .fullScreen
            present(navigationController, animated: true)
        }
    }
    
    private func showExams() {
        let examsController = ExamsController.instantiate(bundle: .module)
        present(examsController, animated: true)
    }
    
}

extension StudyController: UICollectionViewDataSource {
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return quizModes.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let quizMode = quizModes[indexPath.row]
        switch quizMode {
        case .questionOfTheDay:
            let cell = collectionView.dequeueReusableCell(of: QuestionDayCollectionViewCell.self, for: indexPath)
            cell.setup(date: .now)
            if isQuestionOfTheDayQuizEnabled {
                cell.enable()
            } else {
                cell.disable()
            }
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(of: QuizModeCollectionViewCell.self, for: indexPath)
            cell.setup(with: quizMode)
            return cell
        }
    }
    
}

extension StudyController: UICollectionViewDelegate {
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let exam = ExamStorage.shared.getExam(id: Settings.shared.selectedExamId) else {
            showExams()
            return
        }
        let quizMode = quizModes[indexPath.row]
        
        guard !quizMode.isPremium || SCEPKit.isPremium else {
            SCEPKit.showPaywallController(from: self)
            return
        }
        
        guard quizMode != .questionOfTheDay || isQuestionOfTheDayQuizEnabled else { return }
                
        let isPremium = SCEPKit.isPremium
        let subjectIds = Settings.shared.selectedSubjectIds
        let questions = ExamStorage.shared.questions[exam.id]?.filter({ question in
            return question.isFree || isPremium
        }).filter({ question in
            return subjectIds.contains(question.subject.id)
        }) ?? []
        
        guard !questions.isEmpty else  {
            let alert = UIAlertController(title: "Error", message: "There are no questions", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel))
            present(alert, animated: true)
            return
        }
        
        switch quizMode {
        case .timedQuiz:
            let durationController = DurationController.instantiate(bundle: .module)
            durationController.questions = quizMode.filterQuestions(questions)
            presentAutoHeight(durationController)
        case .mistakesQuiz:
            let missedQuestionsController = MissedQuestionsController.instantiate(bundle: .module)
            let wrongAnsweredQuestionIds = Set(ResultStorage.shared.quizResults.flatMap(\.wrongAnsweredQuestions).map(\.objectId))
            missedQuestionsController.questions = questions.filter({ wrongAnsweredQuestionIds.contains($0.objectId) })
            presentAutoHeight(missedQuestionsController)
        case .mockExam:
            let mockExam = exam.mockExams.first ?? MockExam(
                name: exam.descriptiveName,
                duration: 10800,
                description: nil,
                questionSerials: quizMode.filterQuestions(ExamStorage.shared.questions[exam.id] ?? []).map(\.serial)
            )
            let questions = ExamStorage.shared.questions[exam.id]?.filter({ question in
                return mockExam.questionSerials.contains(question.serial)
            }) ?? []
            
            let mockExamPreparationController = MockExamPreparationController.instantiate(bundle: .module)
            mockExamPreparationController.mockExam = mockExam
            mockExamPreparationController.questions = questions
            present(mockExamPreparationController, animated: true)
        default:
            let quizController = QuizController.instantiate(bundle: .module)
            quizController.questions = quizMode.filterQuestions(questions)
            quizController.quizMode = quizMode
            present(quizController, animated: true)
        }
    }
    
}

extension StudyController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let quizMode = quizModes[indexPath.row]
        let contentWidth = collectionView.bounds.width - collectionView.contentInset.left - collectionView.contentInset.right
        switch quizMode {
        case .questionOfTheDay:
            return CGSize(width: contentWidth, height: 56)
        default:
            let spacing = (collectionViewLayout as? UICollectionViewFlowLayout)?.minimumInteritemSpacing ?? 8
            let width = floor((contentWidth - spacing) / 2)
            return CGSize(width: width, height: 192)
        }
    }
    
}

extension StudyController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yOffset = scrollView.contentOffset.y + scrollView.contentInset.top
        header.transform = .init(translationX: 0, y: min(0, yOffset))
        UIView.animate(withDuration: 0.1) {
            self.navigationBarBackgroundView.backgroundColor = yOffset > 174 ? .white : UIColor(resource: .secondaryBackground)
        }
    }
    
}
