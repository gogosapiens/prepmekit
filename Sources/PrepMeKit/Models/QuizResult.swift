import struct Foundation.Date

struct QuizResult: Codable {
    let mode: QuizMode
    let date: Date
    let questions: [Question]
    let selectedChoiceIds: [Question.ID: Set<Choice.ID>]
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
        let selectedChoices = selectedChoiceIds[question.objectId, default: []]
            .compactMap(question.choices.first)
        let correctChoiceCount = selectedChoices.count(where: \.isCorrect)
        let containsWrongChoice = selectedChoices.contains(where: { !$0.isCorrect })
        return correctChoiceCount == question.correctChoiceCount && !containsWrongChoice
    }
}

struct QuizResultV1: Codable {
    let mode: QuizMode
    let date: Date
    let questions: [Question]
    let selectedChoiceIds: [Question.ID: Choice.ID]
    let duration: Int
    let communityScore: Int
}
