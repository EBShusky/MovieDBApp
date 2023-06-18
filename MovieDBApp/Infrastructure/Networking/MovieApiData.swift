import Foundation

struct MovieApiData: Decodable {
    let id: Int
    let overview: String
    let backdropUrl: String?
    let title: String
    let releaseDate: Date
    let rating: Float

    enum CodingKeys: String, CodingKey {
        case id
        case overview
        case backdropUrl = "posterPath"
        case title
        case releaseDate
        case rating = "voteAverage"
    }
}
