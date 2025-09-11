import UIKit
import SCEPKit

class ExamSettingsController: UIViewController {
    
    private enum ExamSetting {
        case switchExam
        case setupExam
        case quizPreferences
        case studyReminder
    }
    
    @IBOutlet private weak var tableView: UITableView!
    
    private let data: [[ExamSetting]] = [[
        .switchExam,
        .setupExam
//    ], [
//        .quizPreferences
//    ], [
//        .studyReminder
    ]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.sectionHeaderTopPadding = 0
        tableView.register(TitleTableViewHeader.self)
        tableView.register(ExamTableViewCell.self)
        tableView.register(SetupExamTableViewCell.self)
        tableView.register(ExamSettingTableViewCell.self)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadDate), name: Settings.didChangeSelectedExamNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadDate), name: ResultStorage.didChangeQuizResultsNotification, object: nil)
    }
    
    @objc private func reloadDate() {
        tableView.reloadData()
    }
    
    @IBAction private func closeClicked(_ sender: Any) {
        dismiss(animated: true)
    }
    
}

extension ExamSettingsController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let setting = data[indexPath.section][indexPath.row]
        switch setting {
        case .switchExam:
            let cell = tableView.dequeueReusableCell(of: ExamTableViewCell.self, for: indexPath)
            if let exam = ExamStorage.shared.getExam(id: Settings.shared.selectedExamId) {
                let studyQuestionCount = Set(ResultStorage.shared.quizResults.flatMap(\.questions).map(\.objectId)).count
                cell.setup(with: exam, studyQuestionCount: studyQuestionCount)
            }
            return cell
        case .setupExam:
            let cell = tableView.dequeueReusableCell(of: SetupExamTableViewCell.self, for: indexPath)
            return cell
        case .quizPreferences:
            let cell = tableView.dequeueReusableCell(of: ExamSettingTableViewCell.self, for: indexPath)
            cell.setup(title: "Quiz preferences", image: UIImage(resource: .quizPreferences))
            return cell
        case .studyReminder:
            let cell = tableView.dequeueReusableCell(of: ExamSettingTableViewCell.self, for: indexPath)
            cell.setup(title: "Study reminders", image: UIImage(resource: .studyReminders))
            return cell
        }
    }
    
}

extension ExamSettingsController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let setting = data[indexPath.section][indexPath.row]
        switch setting {
        case .switchExam:
            let examsController = ExamsController.instantiate(bundle: .module)
            present(examsController, animated: true)
        case .setupExam:
            let setupExamController = SetupExamController.instantiate(bundle: .module)
            navigationController?.pushViewController(setupExamController, animated: true)
        case .quizPreferences:
            let quizPreferencesController = QuizPreferencesController.instantiate(bundle: .module)
            navigationController?.pushViewController(quizPreferencesController, animated: true)
        case .studyReminder:
            let studyRemindersController = StudyRemindersController.instantiate(bundle: .module)
            navigationController?.pushViewController(studyRemindersController, animated: true)
        }
    }
    
    func tableView(
        _ tableView: UITableView,
        viewForHeaderInSection section: Int
    ) -> UIView? {
        guard section == 0 else { return nil }
        let header = tableView.dequeueReusableHeaderFooterView(of: TitleTableViewHeader.self)
        header.setup(
            title: "I’M PREPARING FOR",
            font: SCEPKit.font(ofSize: 14, weight: .medium),
            color: .scepShade1,
            bottomPadding: 12
        )
        return header
    }
    
    func tableView(
        _ tableView: UITableView,
        viewForFooterInSection section: Int
    ) -> UIView? {
        return nil
    }
    
    func tableView(
        _ tableView: UITableView,
        heightForHeaderInSection section: Int
    ) -> CGFloat {
        switch section {
        case 0: return 44
        case 1: return 16
        default: return 8
        }
    }
    
    func tableView(
        _ tableView: UITableView,
        heightForFooterInSection section: Int
    ) -> CGFloat {
        return .leastNonzeroMagnitude
    }
    
}
