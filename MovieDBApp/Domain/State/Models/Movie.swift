import Foundation

public struct Movie: Equatable {
    let id: Int
    let overview: String
    let backdropUrl: String?
    let title: String
    let releaseDate: Date
    let rating: Float
    var isFavourite: Bool
}

extension Movie {
    init(from apiData: MovieApiData,
         isFavourite: Bool,
         baseUrl: String = "https://image.tmdb.org/t/p/w500") {
        self.id = apiData.id
        self.overview = apiData.overview
        self.title = apiData.title
        self.rating = apiData.rating
        self.releaseDate = apiData.releaseDate
        self.isFavourite = isFavourite

        if let apiPath = apiData.backdropUrl {
            self.backdropUrl = baseUrl + apiPath
        } else {
            self.backdropUrl = nil
        }
    }
}
