import UIKit

class SubjectsTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var subjectCountLabel: UILabel!
    
    func setup(numberOfSelectedSubjects: Int, numberOfSubjects: Int) {
        subjectCountLabel.text = "\(numberOfSelectedSubjects) 0f \(numberOfSubjects) Subjects"
    }
    
}
