import Foundation

public enum NetworkMethod {
    case post
    case get
}

extension NetworkMethod {
    var string: String {
        switch self {
        case .post:
            return "POST"
        case .get:
            return "GET"
        }
    }
}

public protocol NetworkRequestable {
    var method: NetworkMethod { get }
    var path: String { get }
    var headers: [String: String]? { get }
    var body: Data? { get }
}

extension URLResponse {
    var isSuccess: Bool {
        guard let response = self as? HTTPURLResponse else {
            return false
        }

        return (200...300).contains(response.statusCode)
    }
}
