import UIKit

class ExamsController: UIViewController {
    
    private struct Section {
        let title: String
        let exams: [Exam]
    }
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
    private let selectedExamId = Settings.shared.selectedExamId
    private var data = [Section]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        data = ExamStorage.shared.exams.sorted(by: { $0.key.name < $1.key.name }).map { examSection, exams in
            return Section(title: examSection.name, exams: exams)
        }
        
        collectionView.contentInset = .init(top: 0, left: 16, bottom: 0, right: 16)
        collectionView.register(TitleCollectionViewHeader.self, kind: UICollectionView.elementKindSectionHeader)
        collectionView.register(ExamCollectionViewCell.self)
        
        view.layoutIfNeeded()
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = CGSize(
                width: collectionView.bounds.width - collectionView.contentInset.left - collectionView.contentInset.right,
                height: 100
            )
        }
    }
    
    @IBAction private func closeClicked(_ sender: Any) {
        dismiss(animated: true)
    }
    
}

extension ExamsController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return data.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(of: TitleCollectionViewHeader.self, kind: UICollectionView.elementKindSectionHeader, for: indexPath)
        let section = data[indexPath.section]
        header.setup(title: section.title.uppercased())
        return header
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return data[section].exams.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(of: ExamCollectionViewCell.self, for: indexPath)
        let exam = data[indexPath.section].exams[indexPath.row]
        let isSelected = exam.id == selectedExamId
        cell.setup(exam: exam, isSelected: isSelected)
        return cell
    }
    
}

extension ExamsController: UICollectionViewDelegate {
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        let exam = data[indexPath.section].exams[indexPath.row]
        Settings.shared.selectedExamId = exam.id
        Settings.shared.selectedSubjectIds = exam.subjects.map(\.id)
        ResultStorage.shared.removeAll()
        dismiss(animated: true)
    }
    
}

extension ExamsController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        return CGSize(width: 0, height: 36)
    }
    
}
