import UIKit
import SCEPKit

@MainActor
class PrepMeKitInternal {
    
    public static let shared = PrepMeKitInternal()
    
    private init() {
        
    }
    
    func configure() {
        setupAppearance()
        
        if Settings.shared.selectedExamId == nil && ExamStorage.shared.isThereOnlyOneExam {
            Settings.shared.selectedExamId = ExamStorage.shared.exams.first?.value.first?.id
        }
        
        if let lastQuizDate = ResultStorage.shared.quizResults.map(\.date).max() {
            let dateComponents = Calendar.current.dateComponents([.day, .month, .year, .calendar], from: lastQuizDate.addingTimeInterval(2 * 86_400))
            if let resetStreakDate = Calendar.current.date(from: dateComponents), Date.now > resetStreakDate {
                ResultStorage.shared.streak = 0
            }
        }
    }
    
    func getRootViewController() -> UIViewController {
        return StudyController.instantiate(bundle: .module)
    }
    
    private func setupAppearance() {
        UITableView.appearance().layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
}
