import UIKit
import SCEPKit
import StoreKit

class QuizResultController: UIViewController {
    
    @IBOutlet private weak var titleLabel: UILabel!
    private let header = ResultHeaderView.instantiate()
    @IBOutlet private weak var collectionView: UICollectionView!
    
    private var selectedQuestionFilter: QuestionFilter?
    private var filteredQuestions = [Question]()
    
    var quizResult: QuizResult!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isModalInPresentation = true
        
        titleLabel.text = quizResult.mode.title + " Result"
        filteredQuestions = quizResult.questions
        
        collectionView.contentInset = .init(top: 544, left: 16, bottom: 16, right: 16)
        collectionView.register(ChoiceResultCollectionViewCell.self)
        
        view.layoutIfNeeded()
        header.frame = .init(x: -16, y: -544, width: collectionView.bounds.width, height: 520)
        header.autoresizingMask = .flexibleWidth
        header.delegate = self
        header.setup(with: quizResult)
        collectionView.addSubview(header)
    }
    
    private func requestReviewIfNeeded() {
        let configVariant = SCEPKit.remoteConfigValue(of: String.self, for: "prepme_kit_config_var")
        let configs = SCEPKit.remoteConfigValue(of: [String: Config].self, for: "prepme_kit_config")
        let config = configVariant.flatMap({ configs?[$0] })
        switch config?.askForRatingAfterQuizMode {
        case "true":
            requestReview()
        case "good_result_only":
            if quizResult.score > 80 {
                requestReview()
            }
        default:
            break
        }
    }
    
    private func requestReview() {
        SCEPKit.trackEvent("[PrepMeKit] asked_for_rating_after_quiz", properties: [
            "quiz_result": quizResult.score
        ])
        
        if let scene = UIApplication.shared.connectedScenes.first(
            where: { $0.activationState == .foregroundActive }
        ) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
    
    @IBAction private func closeClicked(_ sender: Any) {
        presentingViewController?.presentingViewController?.dismiss(animated: true)
        requestReviewIfNeeded()
    }
    
}

extension QuizResultController: UICollectionViewDataSource {
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return filteredQuestions.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(of: ChoiceResultCollectionViewCell.self, for: indexPath)
        let question = filteredQuestions[indexPath.row]
        let isCorrect = quizResult.isCorrectAnswer(question: question)
        cell.setup(question: question, isCorrect: isCorrect)
        return cell
    }
    
}

extension QuizResultController: UICollectionViewDelegate {
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        let quizController = QuizController.instantiate(bundle: .module)
        quizController.questions = filteredQuestions
        quizController.quizMode = .quickTenQuiz
        quizController.isReview = true
        quizController.currentQuestionIndex = indexPath.row
        quizController.selectedChoiceIds = quizResult.selectedChoiceIds
        quizController.confirmedQuestionIds = Set(filteredQuestions.map(\.objectId))
        let title: String
        switch selectedQuestionFilter {
        case .none: title = "Review all"
        case .incorrect: title = "Review incorrect"
        case .correct: title = "Review correct"
        }
        quizController.customTitle = title
        navigationController?.pushViewController(quizController, animated: true)
    }
    
}

extension QuizResultController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = collectionView.bounds.width - collectionView.contentInset.left - collectionView.contentInset.right
        let question = filteredQuestions[indexPath.row]
        let height = ChoiceResultCollectionViewCell.getHeight(for: width, question: question)
        return CGSize(width: width, height: height)
    }
    
}

extension QuizResultController: ResultHeaderViewDelegate {
    
    func resultHeaderViewRetakeQuiz(_ resultHeaderView: ResultHeaderView) {
        let rootController = presentingViewController?.presentingViewController ?? self
        rootController.dismiss(animated: true)
        
        let quizController = QuizController.instantiate(bundle: .module)
        quizController.questions = quizResult.questions
        quizController.quizMode = quizResult.mode
        rootController.present(quizController, animated: true)
    }
    
    func resultHeaderViewAllPage(_ resultHeaderView: ResultHeaderView) {
        selectedQuestionFilter = nil
        filteredQuestions = quizResult.questions
        collectionView.reloadData()
    }
    
    func resultHeaderViewIncorrectPage(_ resultHeaderView: ResultHeaderView) {
        selectedQuestionFilter = .incorrect
        filteredQuestions = quizResult.wrongAnsweredQuestions
        collectionView.reloadData()
    }
    
    func resultHeaderViewCorrectPage(_ resultHeaderView: ResultHeaderView) {
        selectedQuestionFilter = .correct
        filteredQuestions = quizResult.correctAnsweredQuestions
        collectionView.reloadData()
    }
    
}

enum QuestionFilter {
    case incorrect
    case correct
}
