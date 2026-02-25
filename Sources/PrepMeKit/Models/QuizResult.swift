import struct Foundation.Date

struct QuizResult: Codable {
    let mode: QuizMode
    let date: Date
    let questions: [Question]
    let selectedChoiceIds: [Question.ID: [Choice.ID]]
    let selectedSubquestionAnswerIndexes: [Question.ID: [Set<Int>]]
    let duration: Int
    let communityScore: Int
    
    var score: Int {
        return Int(Double(correctAnswerCount) / Double(questions.count) * 100)
    }
    
    var correctAnswerCount: Int {
        return questions.count(where: isCorrectAnswer)
    }
    
    var correctAnsweredQuestions: [Question] {
        return questions.filter(isCorrectAnswer)
    }
    
    var wrongAnsweredQuestions: [Question] {
        return questions.filter({ !isCorrectAnswer(question: $0) })
    }
    
    func isCorrectAnswer(question: Question) -> Bool {
        if question.hasSubquestions {
            return selectedSubquestionAnswerIndexes[question.objectId] == question.correctSubquestionAnswerIndexes
        } else if question.type == .buildList {
            return selectedChoiceIds[question.objectId] == question.correctChoiceIds
        } else {
            return selectedChoiceIds[question.objectId].map(Set.init) == Set(question.correctChoiceIds)
        }
    }
}

struct QuizResultV1: Codable {
    let mode: QuizMode
    let date: Date
    let questions: [QuestionV1]
    let selectedChoiceIds: [Question.ID: Choice.ID]
    let duration: Int
    let communityScore: Int
}
