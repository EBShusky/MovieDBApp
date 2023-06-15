import Foundation
import Networking

public enum ApiCalls: NetworkRequestable {
    case nowPlaying
    case search(query: String)

    public var method: Networking.NetworkMethod {
        return .get
    }

    public var path: String {
        switch self {
        case .nowPlaying:
            return "/movie/now_playing"
        case .search(let query):
            return "/search/movie?query=\(query)"
        }
    }

    public var headers: [String : String]? {
        return nil
    }

    public var body: Data? {
        return nil
    }
}
