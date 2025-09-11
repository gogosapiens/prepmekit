import UIKit

class QuizResultController: UIViewController {
    
    @IBOutlet private weak var titleLabel: UILabel!
    private let header = ResultHeaderView.instantiate()
    @IBOutlet private weak var collectionView: UICollectionView!
    
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
    
    @IBAction private func closeClicked(_ sender: Any) {
        presentingViewController?.presentingViewController?.dismiss(animated: true)
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
        let isCorrect = quizResult.selectedChoiceIds[question.objectId].flatMap(question.choices.first)?.isCorrect == true
        cell.setup(question: question, isCorrect: isCorrect)
        return cell
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
        filteredQuestions = quizResult.questions
        collectionView.reloadData()
    }
    
    func resultHeaderViewIncorrectPage(_ resultHeaderView: ResultHeaderView) {
        filteredQuestions = quizResult.questions.filter {
            quizResult.selectedChoiceIds[$0.objectId].flatMap($0.choices.first)?.isCorrect == false
        }
        collectionView.reloadData()
    }
    
    func resultHeaderViewCorrectPage(_ resultHeaderView: ResultHeaderView) {
        filteredQuestions = quizResult.questions.filter {
            quizResult.selectedChoiceIds[$0.objectId].flatMap($0.choices.first)?.isCorrect == true
        }
        collectionView.reloadData()
    }
    
}
