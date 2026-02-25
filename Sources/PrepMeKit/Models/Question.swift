struct Question: Codable {
    typealias ID = String
    
    let objectId: ID
    let serial: String
    var choices: [Choice]
    let isFree: Bool
    let prompt: String
    let explanation: String
    let subject: Subject
    let references: [String]
    let type: String
    let passage: String?
    let passageLabel: String?
    let passageImage: Image?
    let explanationImage: Image?
    let matrixLabels: MatrixLabels?
    let matrixChoiceLayout: [[String]]?
    let mpmcLabels: [String]?
    
    var correctChoiceIds: [Choice.ID] {
        if type == .buildList {
            return choices.sorted(by: { $1.id > $0.id }).map(\.id)
        } else {
            return choices.filter(\.isCorrect).map(\.id)
        }
    }
    
    var hasSubquestions: Bool {
        return matrixLabels != nil || mpmcLabels != nil
    }
    
    var subquestions: [String] {
        return matrixLabels?.rows ?? mpmcLabels ?? []
    }
    
    var correctSubquestionAnswerIndexes: [Set<Int>] {
        return (0..<subquestions.count).map { subquestionIndex in
            return getCorrectAnswerIndexes(subquestionIndex: subquestionIndex)
        }
    }
    
    func getAnswers(subquestionIndex: Int) -> [String] {
        return matrixLabels?.columns ?? choices.filter(labelIndex: subquestionIndex).map(\.text)
    }
    
    func getCorrectAnswerIndexes(subquestionIndex: Int) -> Set<Int> {
        if let layouts = matrixChoiceLayout?[safe: subquestionIndex] {
            return Set(layouts.enumerated().filter { _, layout in
                return layout.hasPrefix("a")
            }.map(\.offset))
        } else {
            let choices = choices.filter(labelIndex: subquestionIndex)
            return Set(choices.enumerated().filter { _, choice in
                return choice.isCorrect
            }.map(\.offset))
        }
    }
    
    func isCorrect(subquestionIndex: Int, answerIndex: Int) -> Bool {
        if let answer = matrixChoiceLayout?[safe: subquestionIndex]?[safe: answerIndex] {
            return answer.hasPrefix("a")
        } else if let choice = choices.filter(labelIndex: subquestionIndex)[safe: answerIndex] {
            return choice.isCorrect
        } else {
            return false
        }
    }
}

extension String {
    static let multipleChoice = "Multiple Choice"
    static let multipleCorrectResponse = "Multiple Correct Response"
    static let trueFalse = "True/False"
    static let buildList = "Build List"
    static let matrixCheckbox = "Matrix Checkbox"
    static let matrixRadioButton = "Matrix Radio Button"
    static let multiPartMultipleChoice = "Multi-Part Multiple Choice"
}

extension Question {
    struct MatrixLabels: Codable {
        let rows: [String]
        let columns: [String]
    }
}

extension Question {
    struct Image: Codable {
        let url: String
        let altText: String
        let longAltText: String
    }
}

extension Question: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.objectId == rhs.objectId && lhs.serial == rhs.serial
    }
}

extension Question: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(objectId)
        hasher.combine(serial)
    }
}

extension Array where Element == Question {
    func first(id: Question.ID) -> Element? {
        return first(where: { $0.objectId == id })
    }
}

struct QuestionV1: Codable {
    let objectId: String
    let serial: String
    var choices: [Choice]
    let isFree: Bool
    let prompt: String
    let explanation: String
    let subject: Subject
    let references: [String]
}
