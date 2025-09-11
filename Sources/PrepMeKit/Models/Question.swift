struct Question: Codable {
    typealias ID = String
    
    let objectId: ID
    let serial: String
    var choices: [Choice]
    let isFree: Bool
    let prompt: String
    let explanation: String
    let subject: Subject
}

extension Array where Element == Question {
    func first(id: Question.ID) -> Element? {
        return first(where: { $0.objectId == id })
    }
}
