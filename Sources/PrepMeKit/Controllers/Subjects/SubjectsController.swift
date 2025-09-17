import UIKit

@MainActor
protocol SubjectsControllerDelegate: AnyObject {
    func subjectsController(_ subjectsController: SubjectsController, didSelect subjectIds: Set<String>)
}

class SubjectsController: UIViewController {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var examTitleLabel: UILabel!
    @IBOutlet private weak var selectAllButton: UIButton!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var saveButton: UIButton!
    
    var selectedSubjectIds = Set<Subject.ID>()
    var exam: Exam!
    var isEditMode = false
    
    weak var delegate: SubjectsControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = isEditMode ? "Edit subjects" : "Select subjects"
        examTitleLabel.text = isEditMode ? exam.name : nil
        saveButton.setTitle(isEditMode ? "Save" : "Apply", for: .normal)
        
        tableView.sectionHeaderTopPadding = 0
        tableView.register(SubjectTableViewCell.self)
        
        updateButtons()
    }
    
    @IBAction private func closeClicked(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction private func selectAllClicked(_ sender: Any) {
        if selectedSubjectIds.count >= exam.subjects.count {
            selectedSubjectIds.removeAll()
        } else {
            selectedSubjectIds = Set(exam.subjects.map(\.id))
        }
        tableView.reloadData()
        updateButtons()
    }
    
    @IBAction private func saveClicked(_ sender: Any) {
        dismiss(animated: true)
        delegate?.subjectsController(self, didSelect: selectedSubjectIds)
    }
    
    private func updateButtons() {
        UIView.performWithoutAnimation {
            selectAllButton.setTitle(selectedSubjectIds.count >= exam.subjects.count ? "DESELECT ALL" : "SELECT ALL", for: .normal)
            selectAllButton.layoutIfNeeded()
        }
        
        let isSaveEnabled = !selectedSubjectIds.isEmpty
        saveButton.backgroundColor = isSaveEnabled ? .prepMeAccent : .scepShade2
        saveButton.isUserInteractionEnabled = isSaveEnabled
    }
    
}

extension SubjectsController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exam.subjects.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(of: SubjectTableViewCell.self, for: indexPath)
        let subject = exam.subjects[indexPath.row]
        cell.setup(title: subject.name, isChecked: selectedSubjectIds.contains(subject.id), hideSeparator: indexPath.row == 0)
        return cell
    }
    
}

extension SubjectsController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let subject = exam.subjects[indexPath.row]
        if selectedSubjectIds.contains(subject.id) {
            selectedSubjectIds.remove(subject.id)
        } else {
            selectedSubjectIds.insert(subject.id)
        }
        tableView.reloadData()
        updateButtons()
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
        return nil
    }
    
    func tableView(
        _ tableView: UITableView,
        heightForHeaderInSection section: Int
    ) -> CGFloat {
        return .leastNonzeroMagnitude
    }
    
    func tableView(
        _ tableView: UITableView,
        heightForFooterInSection section: Int
    ) -> CGFloat {
        return .leastNonzeroMagnitude
    }
    
}
