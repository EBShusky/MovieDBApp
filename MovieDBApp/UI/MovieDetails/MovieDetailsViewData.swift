import UIKit

public struct MovieDetailsViewData {
    public let movie: Movie

    public let title: String
    public let description: String
    public let rating: String
    public let releaseDateString: String
    public let backdropUrl: String?
    public let isFavourite: Bool

    init(movie: Movie) {
        self.movie = movie

        self.title = movie.title
        self.description = movie.overview
        self.rating = "\(movie.rating)"
        self.backdropUrl = movie.backdropUrl
        self.isFavourite = movie.isFavourite

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-mm-DD"
        self.releaseDateString = dateFormatter.string(from: movie.releaseDate)
    }
}


