import UIKit

class SetupExamController: UIViewController {
    
    private enum Item {
        case exam
        case subjects
        case content
        case reset
    }
    
    @IBOutlet private weak var tableView: UITableView!
    
    private let exam = ExamStorage.shared.getExam(id: Settings.shared.selectedExamId)!
    private let data: [[Item]] = [[
        .exam,
        .subjects
    ], [
        .content
    ], [
        .reset
    ]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.sectionHeaderTopPadding = 0
        tableView.register(SetupExamTitleTableViewCell.self)
        tableView.register(SubjectsTableViewCell.self)
        tableView.register(PrepContentTableViewCell.self)
        tableView.register(ResetProgressTableViewCell.self)
        tableView.register(TitleTableViewFooter.self)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeSelectedExam), name: Settings.didChangeSelectedExamNotification, object: nil)
    }
    
    @objc private func didChangeSelectedExam() {
        tableView.reloadData()
    }
    
    @IBAction private func backClicked(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}

extension SetupExamController: UITableViewDataSource {
    
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
        let item = data[indexPath.section][indexPath.row]
        switch item {
        case .exam:
            let cell = tableView.dequeueReusableCell(of: SetupExamTitleTableViewCell.self, for: indexPath)
            cell.setup(with: exam)
            return cell
        case .subjects:
            let cell = tableView.dequeueReusableCell(of: SubjectsTableViewCell.self, for: indexPath)
            cell.setup(numberOfSelectedSubjects: Settings.shared.selectedSubjectIds.count, numberOfSubjects: exam.subjects.count)
            return cell
        case .content:
            let cell = tableView.dequeueReusableCell(of: PrepContentTableViewCell.self, for: indexPath)
            cell.setup(text: [exam.releaseInfo.name, exam.releaseInfo.description, exam.releaseInfo.message].joined(separator: "\n\n"))
            cell.delegate = self
            return cell
        case .reset:
            return tableView.dequeueReusableCell(of: ResetProgressTableViewCell.self, for: indexPath)
        }
    }
    
}

extension SetupExamController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = data[indexPath.section][indexPath.row]
        switch item {
        case .subjects:
            let subjectsController = SubjectsController.instantiate(bundle: .module)
            subjectsController.exam = exam
            subjectsController.selectedSubjectIds = Set(Settings.shared.selectedSubjectIds)
            subjectsController.isEditMode = true
            subjectsController.delegate = self
            present(subjectsController, animated: true)
        case .reset:
            let alert = UIAlertController(title: "Reset Progress", message: "Are you sure you want to delete your progress for this exam and start over? This cannot be undone.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Yes, Reset progress", style: .destructive, handler: { _ in
                ResultStorage.shared.removeAll()
            }))
            present(alert, animated: true)
        default:
            break
        }
    }
    
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
        guard section == 2 else { return nil }
        let footer = tableView.dequeueReusableHeaderFooterView(of: TitleTableViewFooter.self)
        footer.setup(title: "Resetting your progress will delete all question history and quiz scores for exam.")
        return footer
    }
    
    func tableView(
        _ tableView: UITableView,
        heightForFooterInSection section: Int
    ) -> CGFloat {
        switch section {
        case 2: return 56
        default: return .leastNonzeroMagnitude
        }
    }
    
}

extension SetupExamController: PrepContentTableViewCellDelegate {
    
    func prepContentTableViewCellLearnMoreClicked(
        _ prepContentTableViewCell: PrepContentTableViewCell
    ) {
        
    }
    
}

extension SetupExamController: SubjectsControllerDelegate {
    
    func subjectsController(
        _ subjectsController: SubjectsController,
        didSelect subjectIds: Set<String>
    ) {
        Settings.shared.selectedSubjectIds = Array(subjectIds)
    }
    
}
