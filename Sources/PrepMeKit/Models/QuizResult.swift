import struct Foundation.Date

struct QuizResult: Codable {
    let mode: QuizMode
    let date: Date
    let questions: [Question]
    let selectedChoiceIds: [Question.ID: Choice.ID]
    let duration: Int
    let communityScore: Int
    
    var correctAnswerCount: Int {
        return questions.filter {
            selectedChoiceIds[$0.objectId].flatMap($0.choices.first)?.isCorrect == true
        }.count
    }
}
