import Foundation
import Combine

public protocol NetworkManagerProtocol {
    func request<T: Decodable>(_ request: NetworkRequestable) -> AnyPublisher<T, Error>
    func addGlobalHeaders(_ headers: [String: String])
}

public protocol URLSessionWrapperProtocol {
    func dataTaskPublisherWrapper(for request: URLRequest) -> AnyPublisher<(data: Data, response: URLResponse), URLError>
}

extension URLSession: URLSessionWrapperProtocol {
    public func dataTaskPublisherWrapper(for request: URLRequest) -> AnyPublisher<(data: Data, response: URLResponse), URLError> {
        return self.dataTaskPublisher(for: request)
            .eraseToAnyPublisher()
    }
}

public class NetworkManager: NetworkManagerProtocol {

    private let urlSessionWrapper: URLSessionWrapperProtocol
    private var globalHeaders: [String: String]?
    private let baseUrl: String
    private let jsonDecoder: JSONDecoder

    public init(urlSessionWrapper: URLSessionWrapperProtocol,
                baseUrl: String,
                jsonDecoder: JSONDecoder = JSONDecoder()) {
        self.urlSessionWrapper = urlSessionWrapper
        self.baseUrl = baseUrl
        self.jsonDecoder = jsonDecoder
    }

    public func request<T>(_ request: NetworkRequestable) -> AnyPublisher<T, Error> where T : Decodable {
        do {
            let networkRequest = try makeRequest(request)
            return urlSessionWrapper.dataTaskPublisherWrapper(for: networkRequest)
                .tryMap { data, urlResponse -> Data in
                    guard let url = urlResponse as? HTTPURLResponse else {
                        throw ApiError.invalidResponse
                    }

                    if url.isSuccess {
                        return data
                    }
                    throw ApiError.error
                }
                .decode(type: T.self,
                        decoder: jsonDecoder)
                .map { $0 }
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
    }

    public func addGlobalHeaders(_ headers: [String : String]) {
        globalHeaders = headers
    }

    private func makeRequest(_ request: NetworkRequestable) throws -> URLRequest {
        guard let url = URL(string: baseUrl + request.path) else {
            throw ApiError.invalidUrl
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.string
        urlRequest.httpBody = request.body
        urlRequest.allHTTPHeaderFields = (globalHeaders ?? [:])
            .merging(request.headers ?? [:]) { (_, new) in new }
        return urlRequest
    }
}


