struct Config: Decodable {
    let askForRatingAfterQuizMode: String?
    
    enum CodingKeys: String, CodingKey {
        case askForRatingAfterQuizMode = "ask_for_rating_after_quiz"
    }
}
