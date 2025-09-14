import UIKit

enum QuizMode: Codable, CaseIterable {
    case questionOfTheDay
    case quickTenQuiz
    case timedQuiz
    case mistakesQuiz
    case toughTopicQuiz
    case mockExam
    
    var image: UIImage {
        switch self {
        case .questionOfTheDay: return UIImage(resource: .questionOfTheDay)
        case .quickTenQuiz: return UIImage(resource: .quickTenQuiz)
        case .timedQuiz: return UIImage(resource: .timedQuiz)
        case .mistakesQuiz: return UIImage(resource: .mistakesQuiz)
        case .toughTopicQuiz: return UIImage(resource: .toughTopicQuiz)
        case .mockExam: return UIImage(resource: .mockExam)
        }
    }
    
    var title: String {
        switch self {
        case .questionOfTheDay: return "Question of the day"
        case .quickTenQuiz: return "Quick 10 Quiz"
        case .timedQuiz: return "Timed Quiz"
        case .mistakesQuiz: return "Mistakes Quiz"
        case .toughTopicQuiz: return "Tough topic Quiz"
        case .mockExam: return "Mock exam"
        }
    }
    
    var isPremium: Bool {
        switch self {
        case .questionOfTheDay, .quickTenQuiz, .timedQuiz: return false
        default: return true
        }
    }
    
    func filterQuestions(_ questions: [Question]) -> [Question] {
        switch self {
        case .questionOfTheDay:
            return [questions.randomElement()].compactMap({ $0 })
        case .quickTenQuiz:
            return Array(questions.shuffled().prefix(10))
        case .timedQuiz:
            return questions.shuffled()
        case .mistakesQuiz:
            return questions
        case .toughTopicQuiz:
            guard let subjectId = questions.map(\.subject.id).randomElement() else { return [] }
            return Array(questions.filter({ $0.subject.id == subjectId }).shuffled().prefix(10))
        case .mockExam:
            return Array(questions.shuffled().prefix(150))
        }
    }
}
