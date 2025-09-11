import UIKit

class MockExamDetailsView: UIView {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var detailsView: UIView!
    @IBOutlet private weak var questionCountLabel: UILabel!
    @IBOutlet private weak var durationLabel: UILabel!
    @IBOutlet private weak var accessibilityImageView: UIImageView!
    
    private(set) var isAccessibilityEnabled = false
    
    var mockExam: MockExam!
    
    func setup(with mockExam: MockExam) {
        self.mockExam = mockExam
        
        titleLabel.text = "Our mock exam imitates both the time limit and question count of the \(mockExam.name)."
        descriptionLabel.text = mockExam.description?.removingHTMLTags()
        descriptionLabel.isHidden = mockExam.description == nil
        detailsView.layer.borderWidth = 1
        detailsView.layer.borderColor = UIColor.scepShade2.cgColor
        questionCountLabel.text = "\(mockExam.questionSerials.count) Questions"
        updateDetails()
    }
    
    @IBAction private func accessibilityClicked(_ sender: Any) {
        isAccessibilityEnabled.toggle()
        updateDetails()
    }
    
    private func updateDetails() {
        let duration = mockExam.duration + (isAccessibilityEnabled ? 1800 : 0)
        let hours = duration / 3600
        let minutes = duration / 60 % 60
        var timeComponents = [
            String(minutes) + "m"
        ]
        if hours > 0 {
            timeComponents.append(String(hours) + "h")
        }
        durationLabel.text = timeComponents.reversed().joined(separator: " ")
        accessibilityImageView.image = UIImage(resource: isAccessibilityEnabled ? .checkboxChecked : .checkboxUnchecked)
    }
    
}
