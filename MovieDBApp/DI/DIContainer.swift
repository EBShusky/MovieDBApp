import Foundation
import Networking

public class DIContainer {
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

    lazy var movieListState: AnyStateRepository<Loadable<Pagination<Movie>>> = AnyStateRepository(initialState: Loadable(item: Pagination(items: [],
                                                                                                                                     currentPage: 0,
                                                                                                                                     pages: 0),
                                                                                                                    state: .initial))

    lazy var movieListUseCase: MovieListUseCaseProtocol = {
        return MovieListUseCase(networkManager: networkManager,
                                movieListState: movieListState)
    }()
}
