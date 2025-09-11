import UIKit

class SetupExamTitleTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    
    func setup(with exam: Exam) {
        titleLabel.text = exam.name
        subtitleLabel.text = exam.descriptiveName
    }
    
}
