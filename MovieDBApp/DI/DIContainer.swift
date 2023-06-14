import Foundation
import Networking

public class DIContainer {
    let networkManager: NetworkManagerProtocol = {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase

        let networkManager = NetworkManager(urlSessionWrapper: URLSession.shared,
                       baseUrl: "https://api.themoviedb.org/3/",
        jsonDecoder: jsonDecoder)
        networkManager.addGlobalHeaders([
            "Authorization": "Bearer \(Keys.movieDBKey.rawValue)"
        ])
        return networkManager
    }()
}
