import UIKit

class ExamSettingTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var settingImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    
    func setup(title: String, image: UIImage) {
        settingImageView.image = image
        titleLabel.text = title
    }
    
}
