struct Choice: Codable {
    typealias ID = String
    
    let id: ID
    let text: String
    let isCorrect: Bool
    let labelIndex: Int?
}

extension Array where Element == Choice {
    func first(id: Choice.ID) -> Element? {
        return first(where: { $0.id == id })
    }
    
    func filter(labelIndex: Int) -> [Element] {
        return filter({ $0.labelIndex == labelIndex })
    }
}
