import UIKit

class MockExamPreparationController: UIViewController {
    
    @IBOutlet private weak var pageLabel: UILabel!
    @IBOutlet private weak var continueButton: UIButton!
    @IBOutlet private weak var scrollView: UIScrollView!
    private let detailsView = MockExamDetailsView.instantiate()
    private let instructionView = MockExamInstructionView.instantiate()
    
    private var pageNumber = 1
    
    var mockExam: MockExam!
    var questions = [Question]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDetailsPage()
    }
    
    private func setupDetailsPage() {
        detailsView.setup(with: mockExam)
        detailsView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(detailsView)
        NSLayoutConstraint.activate([
            detailsView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            detailsView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            detailsView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            detailsView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            detailsView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor),
            detailsView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor),
        ])
    }
    
    private func setupInstructionPage() {
        instructionView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(instructionView)
        NSLayoutConstraint.activate([
            instructionView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            instructionView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            instructionView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            instructionView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            instructionView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor),
            instructionView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor),
        ])
    }
    
    @IBAction private func closeClicked(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction private func continueClicked(_ sender: Any) {
        pageNumber += 1
        if pageNumber >= 3 {
            dismiss(animated: true)
            
            let quizController = QuizController.instantiate(bundle: .module)
            quizController.questions = questions
            quizController.quizMode = .mockExam
            quizController.remainingSeconds = mockExam.duration + (detailsView.isAccessibilityEnabled ? 1800 : 0)
            presentingViewController?.present(quizController, animated: true)
        } else {
            pageLabel.text = String(pageNumber) + "/2"
            continueButton.setTitle("Start Quiz", for: .normal)
            
            guard let snapshot = scrollView.snapshotView(afterScreenUpdates: false) else { return }
            snapshot.frame = scrollView.frame
            view.insertSubview(snapshot, belowSubview: scrollView)
            
            detailsView.removeFromSuperview()
            setupInstructionPage()
            scrollView.transform = .init(translationX: scrollView.bounds.width, y: 0)
            
            UIView.animate(withDuration: 0.25) {
                snapshot.transform = .init(translationX: -snapshot.bounds.width, y: 0)
                self.scrollView.transform = .identity
            } completion: { _ in
                snapshot.removeFromSuperview()
            }
        }
    }
    
}
