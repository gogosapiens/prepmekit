import UIKit

class StudyHeaderView: UIView {
    
    private enum Tab {
        case allStudying
        case qotd
    }
    
    @IBOutlet private weak var allStudyingButton: UIButton!
    @IBOutlet private weak var qotdButton: UIButton!
    @IBOutlet private weak var streakImageView: UIImageView!
    @IBOutlet private weak var streakLabel: UILabel!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var quizModesBackgroundView: UIView!
    
    private var dates = [Date]()
    private var studyDates = [Date]()
    private var qotdResults = [QuizResult]()
    private var tab: Tab = .allStudying
    
    override func awakeFromNib() {
        super.awakeFromNib()
        allStudyingButton.layer.borderWidth = 1
        allStudyingButton.layer.borderColor = UIColor.prepMeAccent.cgColor
        qotdButton.layer.borderWidth = 1
        qotdButton.layer.borderColor = UIColor.clear.cgColor
        collectionView.register(DayCollectionViewCell.self)
        quizModesBackgroundView.layer.cornerRadius = 20
        quizModesBackgroundView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: ResultStorage.didChangeQuizResultsNotification, object: nil)
    }
    
    func setup(dates: [Date], isStreakActive: Bool, streak: Int) {
        self.dates = dates
        
        streakImageView.image = UIImage(resource: isStreakActive ? .fire : .fireInactive)
        streakLabel.textColor = isStreakActive ? .scepTextColor : .scepShade1
        streakLabel.text = "\(streak) Day\(streak == 1 ? "" : "s") streak"
        
        let itemWidth: CGFloat = 49
        let spacing: CGFloat = 12
        let numberOfItems = dates.count
        let contentWidth = CGFloat(numberOfItems) * itemWidth + CGFloat(numberOfItems - 1) * spacing
        collectionView.contentInset.left = -(contentWidth - UIScreen.main.bounds.width) / 2
        reloadData()
    }
    
    @objc private func reloadData() {
        studyDates = ResultStorage.shared.quizResults.filter({ $0.mode != .questionOfTheDay }).map(\.date)
        qotdResults = ResultStorage.shared.quizResults.filter({ $0.mode == .questionOfTheDay })
        collectionView.reloadData()
    }
    
    @IBAction private func allStudyingClicked(_ sender: Any) {
        allStudyingButton.layer.borderColor = UIColor.prepMeAccent.cgColor
        allStudyingButton.setTitleColor(.prepMeAccent, for: .normal)
        qotdButton.layer.borderColor = UIColor.clear.cgColor
        qotdButton.setTitleColor(.scepTextColor, for: .normal)
        tab = .allStudying
        collectionView.reloadData()
    }
    
    @IBAction private func qotdClicked(_ sender: Any) {
        allStudyingButton.layer.borderColor = UIColor.clear.cgColor
        allStudyingButton.setTitleColor(.scepTextColor, for: .normal)
        qotdButton.layer.borderColor = UIColor.prepMeAccent.cgColor
        qotdButton.setTitleColor(.prepMeAccent, for: .normal)
        tab = .qotd
        collectionView.reloadData()
    }
    
}

extension StudyHeaderView: UICollectionViewDataSource {
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return dates.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(of: DayCollectionViewCell.self, for: indexPath)
        let date = dates[indexPath.row]
        let calendar = Calendar.current
        let indicatorColor: UIColor
        switch tab {
        case .allStudying:
            indicatorColor = studyDates.contains(where: { calendar.isDate($0, inSameDayAs: date) }) ? .prepMeAccent : .clear
        case .qotd:
            if let result = qotdResults.first(where: { calendar.isDate($0.date, inSameDayAs: date) }) {
                indicatorColor = UIColor(resource: result.correctAnswerCount > 0 ? .correct : .wrong)
            } else {
                indicatorColor = .clear
            }
        }
        let isSelected = indexPath.row == dates.count / 2
        cell.setup(date: date, indicatorColor: indicatorColor, isSelected: isSelected)
        return cell
    }
    
}
