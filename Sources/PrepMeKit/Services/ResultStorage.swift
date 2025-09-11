import Foundation

@MainActor
class ResultStorage {
    
    static let didChangeQuizResultsNotification = Notification.Name("ResultStorage.didChangeQuizResultsNotification")
    
    static let shared = ResultStorage()
    
    @UserDefault(key: "ResultStorage.quizResults", defaultValue: [])
    var quizResults: [QuizResult]
    
    @UserDefault(key: "ResultStorage.streak", defaultValue: 0)
    var streak: Int
    
    private init() {
        
    }
    
    func save(quizResult: QuizResult) {
        let calendar = Calendar.current
        let isStreakActive = quizResults.contains { quizResult in
            return calendar.isDateInToday(quizResult.date)
        }
        if !isStreakActive {
            streak += 1
        }
        
        quizResults.append(quizResult)
        NotificationCenter.default.post(name: Self.didChangeQuizResultsNotification, object: nil)
    }
    
    func removeAll() {
        quizResults.removeAll()
        streak = 0
        NotificationCenter.default.post(name: Self.didChangeQuizResultsNotification, object: nil)
    }
    
}
