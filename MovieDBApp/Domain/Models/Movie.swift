public struct Movie: Equatable {
    let id: Int
    let overview: String
    let backdropUrl: String
    let title: String
    let isFavourite: Bool
}

extension Movie {
    init(from apiData: MovieApiData,
         isFavourite: Bool,
         baseUrl: String = "https://image.tmdb.org/t/p/w500") {
        self.id = apiData.id
        self.overview = apiData.overview
        self.backdropUrl = baseUrl + apiData.backdropUrl
        self.title = apiData.title
        self.isFavourite = isFavourite
    }
}
