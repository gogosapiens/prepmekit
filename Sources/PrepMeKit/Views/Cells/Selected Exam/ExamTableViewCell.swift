import UIKit

class ExamTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var switchExamButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        stackView.setCustomSpacing(16, after: descriptionLabel)
    }
    
    func setup(with exam: Exam, studyQuestionCount: Int, hideSwitchButton: Bool) {
        titleLabel.text = exam.name
        subtitleLabel.text = exam.descriptiveName
        descriptionLabel.text = "Study progress • \(studyQuestionCount)/\(exam.questionCount) questions"
        switchExamButton.isHidden = hideSwitchButton
    }
    
}
