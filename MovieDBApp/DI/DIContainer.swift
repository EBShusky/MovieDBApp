import Foundation
import Networking

// Could be migrated to some more fancy solution like Swinject
public class DIContainer {
    lazy var codablePersistentStorage: CodableKeyedPersistentStorageProtocol = {
        return UserDefaults(suiteName: "PersistentStorage")!
    }()

    lazy var networkManager: NetworkManagerProtocol = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-mm-DD"

        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)

        let networkManager = NetworkManager(urlSessionWrapper: URLSession.shared,
                                            baseUrl: Config.apiBaseUrl,
                                            jsonDecoder: jsonDecoder)
        networkManager.addGlobalHeaders([
            "Authorization": "Bearer \(Keys.movieDBKey.rawValue)"
        ])
        return networkManager
    }()

    lazy var movieListState: AnyStateRepository<Loadable<Pagination<Movie>>> = AnyStateRepository(repository: InMemoryStateRepository(initialState: Loadable(item: Pagination(items: [],
                                                                                                                                                                              currentPage: 0,
                                                                                                                                                                              pages: 0),
                                                                                                                                                             state: .initial)))

    private var movieDetailsStateShared: AnyStateRepository<Movie>?
    func movieDetailsState(movie: Movie) -> AnyStateRepository<Movie> {
        let movieDetailsStateShared = AnyStateRepository(repository: InMemoryStateRepository(initialState: movie))
        self.movieDetailsStateShared = movieDetailsStateShared
        return movieDetailsStateShared
    }

    lazy var favouriteMovieState: AnyStateRepository<[Int]> = AnyStateRepository(repository: UserDefaultsFavouritesStateRepository(codableStorage: codablePersistentStorage,
                                                                                                                                   key: "FavouriteIds"))

    lazy var movieListUseCase: MovieListUseCaseProtocol = {
        return MovieListUseCase(networkManager: networkManager,
                                movieListState: movieListState,
                                favouriteMovieState: favouriteMovieState)
    }()

    func favouriteUseCase() -> FavouriteMovieUseCaseProtocol {
        return FavouriteMovieUseCase(movieListState: movieListState,
                                     favouriteMovieState: favouriteMovieState,
                                     movieDetailState: movieDetailsStateShared)
    }
}
