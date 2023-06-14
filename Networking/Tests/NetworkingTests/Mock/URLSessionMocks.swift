import Foundation
import Combine
@testable import Networking

class MockURLSessionWrapper: URLSessionWrapperProtocol {

    var dataTaskPublisherWrapperCalled: Bool = false
    var dataTaskPublisherWrapperParameter: URLRequest!
    var dataTaskPublisherWrapperReturn:  AnyPublisher<(data: Data, response: URLResponse), URLError>!
    func dataTaskPublisherWrapper(for request: URLRequest) -> AnyPublisher<(data: Data, response: URLResponse), URLError> {
        dataTaskPublisherWrapperCalled = true
        dataTaskPublisherWrapperParameter = request
        return dataTaskPublisherWrapperReturn
    }
}
