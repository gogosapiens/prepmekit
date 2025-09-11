import Foundation

@MainActor
class Settings {
    
    static let didChangeSelectedExamNotification = Notification.Name("Settings.didChangeSelectedExamNotification")
    
    static let shared = Settings()
    
    @UserDefault(key: "Settings.answerReveal", defaultValue: .afterEachQuestion)
    var answerReveal: AnswerReveal
    
    @UserDefault(key: "Settings.answerSubmit", defaultValue: .automatic)
    var answerSubmit: AnswerSubmit
    
    @UserDefault(key: "Settings.subjectOrder", defaultValue: .decreasingScore)
    var subjectOrder: SubjectOrder
    
    @UserDefault(key: "Settings.selectedExamId", defaultValue: nil)
    var selectedExamId: Exam.ID? {
        didSet {
            NotificationCenter.default.post(name: Self.didChangeSelectedExamNotification, object: nil)
        }
    }
    
    @UserDefault(key: "Settings.selectedSubjectIds", defaultValue: [])
    var selectedSubjectIds: [Subject.ID] {
        didSet {
            NotificationCenter.default.post(name: Self.didChangeSelectedExamNotification, object: nil)
        }
    }
    
    private init() {
        
    }
    
}

enum AnswerReveal: Codable {
    case afterEachQuestion
    case afterSubmittingQuiz
    
    var title: String {
        switch self {
        case .afterEachQuestion: return "After each question"
        case .afterSubmittingQuiz: return "After submitting quiz"
        }
    }
}

enum AnswerSubmit: Codable {
    case automatic
    case manual
    
    var title: String {
        switch self {
        case .automatic: return "Automatic: Tap answer choice"
        case .manual: return "Manual: Tap “Check answer”"
        }
    }
}

enum SubjectOrder: Codable {
    case decreasingScore
    case increasingScore
    case alphabetical
    
    var title: String {
        switch self {
        case .decreasingScore: return "Highest to lowest score"
        case .increasingScore: return "Lowest to highest score"
        case .alphabetical: return "Alphabetical"
        }
    }
}
