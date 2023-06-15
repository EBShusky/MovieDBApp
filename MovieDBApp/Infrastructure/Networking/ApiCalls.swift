import Foundation
import Networking

public enum ApiCalls: NetworkRequestable {
    case nowPlaying(page: Int)
    case search(query: String)

    public var method: Networking.NetworkMethod {
        return .get
    }

    public var path: String {
        switch self {
        case .nowPlaying(let page):
            return page == 0 ? "/movie/now_playing" : "/movie/now_playing?page=\(page)"
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
