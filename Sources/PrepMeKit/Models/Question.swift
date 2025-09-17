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
