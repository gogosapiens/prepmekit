struct Choice: Codable {
    typealias ID = String
    
    let id: ID
    let text: String
    let isCorrect: Bool
}

extension Array where Element == Choice {
    func first(id: Choice.ID) -> Element? {
        return first(where: { $0.id == id })
    }
}
