import UIKit
import SCEPKit

fileprivate enum Preference {
    case answerReveal(AnswerReveal)
    case answerSubmit(AnswerSubmit)
    case subjectOrder(SubjectOrder)
    
    var title: String {
        switch self {
        case .answerReveal: return "When do you want to see the correct answer and explanation?"
        case .answerSubmit: return "How do you want to submit your answers?"
        case .subjectOrder: return "Subject order"
        }
    }
    
    var value: String {
        switch self {
        case .answerReveal(let answerReveal): return answerReveal.title
        case .answerSubmit(let answerSubmit): return answerSubmit.title
        case .subjectOrder(let subjectOrder): return subjectOrder.title
        }
    }
}

class QuizPreferencesController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    
    private let preferences: [[Preference]] = [[
        .answerReveal(.afterEachQuestion),
        .answerReveal(.afterSubmittingQuiz)
    ], [
        .answerSubmit(.automatic),
        .answerSubmit(.manual)
    ], [
        .subjectOrder(.decreasingScore),
        .subjectOrder(.increasingScore),
        .subjectOrder(.alphabetical)
    ]]
    private var answerReveal: AnswerReveal = .afterEachQuestion
    private var answerSubmit: AnswerSubmit = .automatic
    private var subjectOrder: SubjectOrder = .decreasingScore
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        answerReveal = Settings.shared.answerReveal
        answerSubmit = Settings.shared.answerSubmit
        subjectOrder = Settings.shared.subjectOrder
        
        tableView.contentInset.top = 16
        tableView.register(TitleTableViewHeader.self)
        tableView.register(RadioButtonTableViewCell.self)
    }
    
    @IBAction private func backClicked(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction private func saveClicked(_ sender: Any) {
        Settings.shared.answerReveal = answerReveal
        Settings.shared.answerSubmit = answerSubmit
        Settings.shared.subjectOrder = subjectOrder
        navigationController?.popViewController(animated: true)
    }
    
}

extension QuizPreferencesController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return preferences.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return preferences[section].count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(of: RadioButtonTableViewCell.self, for: indexPath)
        let preference = preferences[indexPath.section][indexPath.row]
        let isChecked: Bool
        switch preference {
        case .answerReveal(let answerReveal): isChecked = answerReveal == self.answerReveal
        case .answerSubmit(let answerSubmit): isChecked = answerSubmit == self.answerSubmit
        case .subjectOrder(let subjectOrder): isChecked = subjectOrder == self.subjectOrder
        }
        cell.setup(title: preference.value, isChecked: isChecked, hideSeparator: indexPath.row == 0)
        return cell
    }
    
}

extension QuizPreferencesController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let preference = preferences[indexPath.section][indexPath.row]
        switch preference {
        case .answerReveal(let answerReveal): self.answerReveal = answerReveal
        case .answerSubmit(let answerSubmit): self.answerSubmit = answerSubmit
        case .subjectOrder(let subjectOrder): self.subjectOrder = subjectOrder
        }
        tableView.reloadData()
    }
    
    func tableView(
        _ tableView: UITableView,
        viewForHeaderInSection section: Int
    ) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(of: TitleTableViewHeader.self)
        guard let preference = preferences[section].first else { return nil }
        header.setup(
            title: preference.title,
            font: SCEPKit.font(ofSize: 14, weight: .medium),
            color: .scepTextColor,
            bottomPadding: 16
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
        heightForFooterInSection section: Int
    ) -> CGFloat {
        return section >= preferences.count - 1 ? .leastNonzeroMagnitude : 24
    }
    
}
