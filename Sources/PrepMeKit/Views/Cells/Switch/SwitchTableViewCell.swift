import UIKit

@MainActor
protocol SwitchTableViewCellDelegate: AnyObject {
    func switchTableViewCell(_ switchTableViewCell: SwitchTableViewCell, didChange value: Bool)
}

class SwitchTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var switchControl: UISwitch!
    
    weak var delegate: SwitchTableViewCellDelegate?
    
    func setup(title: String, subtitle: String, isOn: Bool) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        switchControl.isOn = isOn
    }
    
    @IBAction private func switchChanged(_ sender: Any) {
        delegate?.switchTableViewCell(self, didChange: switchControl.isOn)
    }
    
}
