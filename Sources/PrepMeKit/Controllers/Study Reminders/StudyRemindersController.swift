import UIKit

class StudyRemindersController: UIViewController {
    
    @IBOutlet private weak var warningView: UIStackView!
    @IBOutlet private weak var settingsButton: UIButton!
    @IBOutlet private weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        warningView.isHidden = true
        settingsButton.isHidden = true
        tableView.register(SwitchTableViewCell.self)
    }
    
    @IBAction private func backClicked(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction private func settingsClicked(_ sender: Any) {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
    
}

extension StudyRemindersController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(of: SwitchTableViewCell.self, for: indexPath)
        cell.delegate = self
        switch indexPath.section {
        case 0:
            cell.setup(title: "Question of the day", subtitle: "Notifications with today’s Question of the day.", isOn: false)
        case 1:
            cell.setup(title: "Study reminder", subtitle: "Nudge yourself to study consistently with a custom message.", isOn: false)
        default:
            break
        }
        return cell
    }
    
}

extension StudyRemindersController: UITableViewDelegate {
    
    func tableView(
        _ tableView: UITableView,
        viewForHeaderInSection section: Int
    ) -> UIView? {
        return nil
    }
    
    func tableView(
        _ tableView: UITableView,
        viewForFooterInSection section: Int
    ) -> UIView? {
        return nil
    }
    
    func tableView(
        _ tableView: UITableView,
        heightForFooterInSection section: Int
    ) -> CGFloat {
        return .leastNonzeroMagnitude
    }
    
}

extension StudyRemindersController: SwitchTableViewCellDelegate {
    
    func switchTableViewCell(
        _ switchTableViewCell: SwitchTableViewCell,
        didChange value: Bool
    ) {
        
    }
    
}
