import UIKit

class ExamTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    func setup(with exam: Exam, studyQuestionCount: Int) {
        titleLabel.text = exam.name
        subtitleLabel.text = exam.descriptiveName
        descriptionLabel.text = "Study progress • \(studyQuestionCount)/\(exam.questionCount) questions"
    }
    
}
