struct MockExam: Decodable {
    let name: String
    let duration: Int
    let description: String?
    let questionSerials: [String]
    
    enum CodingKeys: String, CodingKey {
        case name
        case duration = "durationSeconds"
        case description
        case questionSerials
    }
}
