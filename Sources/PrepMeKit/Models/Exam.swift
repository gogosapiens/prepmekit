struct Exam: Decodable {
    typealias ID = String
    
    let id: ID
    let name: String
    let descriptiveName: String
    let fileName: String
    let subjects: [Subject]
    let releaseInfo: ReleaseInfo
    let questionCount: Int
    let mockExams: [MockExam]
    
    enum CodingKeys: String, CodingKey {
        case id = "objectId"
        case name = "examName"
        case descriptiveName
        case fileName = "examFileName"
        case subjects = "knowledgeAreas"
        case releaseInfo
        case questionCount = "questionsCount"
        case mockExams
    }
}

extension Exam {
    struct ReleaseInfo: Decodable {
        let name: String
        let description: String
        let message: String
    }
}
