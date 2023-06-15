import Networking
import Combine

class NetworkManagerMock<T>: NetworkManagerProtocol {

    var response: T?
    var error: Error?

    public func request<T>(_ request: Networking.NetworkRequestable) -> AnyPublisher<T, Error> {
        if let response = response as? T {
            return Just(response)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()

        } else if let error = error {
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
        return Fail(error: ApiError.invalidResponse)
            .eraseToAnyPublisher()
    }

    public func addGlobalHeaders(_ headers: [String : String]) {

    }
}
