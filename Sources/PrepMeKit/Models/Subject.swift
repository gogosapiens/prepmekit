struct Subject: Codable {
    typealias ID = String
    
    let id: ID
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case id = "objectId"
        case name
    }
}
