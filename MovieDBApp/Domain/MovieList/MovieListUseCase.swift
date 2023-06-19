import Foundation
import Combine
import Networking

public protocol MovieListUseCaseProtocol {
    func nextPage()
    func reload()
}

public class MovieListUseCase: MovieListUseCaseProtocol {
    private let networkManager: NetworkManagerProtocol
    private let movieListState: AnyStateRepository<Loadable<Pagination<Movie>>>
    private let favouriteMovieState: AnyStateRepository<[Int]>
    private var disposeBag: Set<AnyCancellable> = Set()

    public init(networkManager: NetworkManagerProtocol,
                movieListState: AnyStateRepository<Loadable<Pagination<Movie>>>,
                favouriteMovieState: AnyStateRepository<[Int]>) {
        self.networkManager = networkManager
        self.movieListState = movieListState
        self.favouriteMovieState = favouriteMovieState
    }

    public func nextPage() {
        disposeBag.removeAll()
        let request: AnyPublisher<EnvelopedResponse<[MovieApiData]>, Error> = networkManager.request(ApiCalls.nowPlaying(page: movieListState.current.item.currentPage + 1))

        request.handleEvents(receiveSubscription: { [weak movieListState] _ in
                if var state = movieListState?.current {
                    state.state = .loading
                    movieListState?.update(state)
                }
            })
            .map({ [weak self] response -> Pagination<Movie> in
                return Pagination(items: response.results.map { Movie(from: $0,
                                                                      isFavourite: self?.checkIfFavourite(id: $0.id) ?? false) },
                                  currentPage: response.page,
                                  pages: response.totalPages)
            })
            .sink { [weak movieListState] completion in
                guard var state = movieListState?.current else {
                    return
                }

                switch completion {
                case .finished:
                    state.state = .loaded
                case .failure(_):
                    state.state = .error
                }
                movieListState?.update(state)
            } receiveValue: { [weak movieListState] newState in
                if var state = movieListState?.current {
                    state.item.consume(newState)
                    movieListState?.update(state)
                }
            }
            .store(in: &disposeBag)
    }

    public func reload() {
        disposeBag.removeAll()
        let request: AnyPublisher<EnvelopedResponse<[MovieApiData]>, Error> = networkManager.request(ApiCalls.nowPlaying(page: 0))

        request.handleEvents(receiveSubscription: { [weak movieListState] _ in
                if var state = movieListState?.current {
                    state.state = .loading
                    movieListState?.update(state)
                }
            })
            .map({ [weak self] response -> Pagination<Movie> in
                return Pagination(items: response.results.map { Movie(from: $0,
                                                                      isFavourite: self?.checkIfFavourite(id: $0.id) ?? false) },
                                  currentPage: response.page,
                                  pages: response.totalPages)
            })
            .sink { [weak movieListState] completion in
                guard var state = movieListState?.current else {
                    return
                }

                switch completion {
                case .finished:
                    state.state = .loaded
                case .failure(_):
                    state.state = .error
                }
                movieListState?.update(state)
            } receiveValue: { [weak movieListState] newState in
                if var state = movieListState?.current {
                    state.item = newState
                    movieListState?.update(state)
                }
            }
            .store(in: &disposeBag)
    }

    func checkIfFavourite(id: Int) -> Bool {
        return favouriteMovieState.current.contains(id)
    }
}


