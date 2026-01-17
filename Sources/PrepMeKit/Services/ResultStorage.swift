import Foundation

@MainActor
class ResultStorage {
    
    static let didChangeQuizResultsNotification = Notification.Name("ResultStorage.didChangeQuizResultsNotification")
    
    static let shared = ResultStorage()
    
    @UserDefault(key: "ResultStorage.quizResults", defaultValue: [])
    private var quizResultsV1: [QuizResultV1]
    
    @UserDefault(key: "ResultStorage.quizResults.v2", defaultValue: [])
    var quizResults: [QuizResult]
    
    @UserDefault(key: "ResultStorage.streak", defaultValue: 0)
    var streak: Int
    
    private init() {
        
    }
    
    func migrate() {
        if quizResultsV1.isEmpty { return }
        
        for quizResultV1 in quizResultsV1 {
            quizResults.append(QuizResult(
                mode: quizResultV1.mode,
                date: quizResultV1.date,
                questions: quizResultV1.questions,
                selectedChoiceIds: .init(
                    uniqueKeysWithValues: quizResultV1.selectedChoiceIds.map({ ($0.key, [$0.value]) })
                ),
                duration: quizResultV1.duration,
                communityScore: quizResultV1.communityScore
            ))
        }
        
        quizResultsV1.removeAll()
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
