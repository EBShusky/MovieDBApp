struct MovieApiData: Decodable {
    let id: Int
    let overview: String
    let backdropUrl: String
    let title: String

    enum CodingKeys: String, CodingKey {
        case id
        case overview
        case backdropUrl = "posterPath"
        case title
    }
}
