import Combine

public protocol FavouriteMovieUseCaseProtocol {
    func favouriteMovie(movie: Movie)
    func unfavouriteMovie(movie: Movie)
}

public class FavouriteMovieUseCase: FavouriteMovieUseCaseProtocol {

    private let movieListState: AnyStateRepository<Loadable<Pagination<Movie>>>
    private let favouriteMovieState: AnyStateRepository<[Int]>
    private let movieDetailState: AnyStateRepository<Movie>?

    init(movieListState: AnyStateRepository<Loadable<Pagination<Movie>>>,
         favouriteMovieState: AnyStateRepository<[Int]>,
         movieDetailState: AnyStateRepository<Movie>?) {
        self.movieListState = movieListState
        self.favouriteMovieState = favouriteMovieState
        self.movieDetailState = movieDetailState
    }

    public func favouriteMovie(movie: Movie) {
        var state = favouriteMovieState.current
        state.append(movie.id)
        favouriteMovieState.update(state)

        movieListState.updateFavourite(id: movie.id)

        var movie = movie
        movie.isFavourite = true
        movieDetailState?.update(movie)
    }

    public func unfavouriteMovie(movie: Movie) {
        var state = favouriteMovieState.current
        state.removeAll { $0 == (movie.id) }
        favouriteMovieState.update(state)

        movieListState.updateUnfavourite(id: movie.id)

        var movie = movie
        movie.isFavourite = false
        movieDetailState?.update(movie)
    }
}

private extension AnyStateRepository where T == Loadable<Pagination<Movie>> {
    func updateFavourite(id: Int) {
        var state = current
        for i in 0..<state.item.items.count {
            if state.item.items[i].id == id {
                state.item.items[i].isFavourite = true
            }
        }
        update(state)
    }

    func updateUnfavourite(id: Int) {
        var state = current
        for i in 0..<state.item.items.count {
            if state.item.items[i].id == id {
                state.item.items[i].isFavourite = false
            }
        }
        update(state)
    }
}
