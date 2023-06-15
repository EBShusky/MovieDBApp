import XCTest
import Combine
@testable import Networking

final class NetworkManagerTests: XCTestCase {
    var networkManager: NetworkManager!
    var baseUrl: String!
    var urlSessionWrapper: MockURLSessionWrapper!

    var disposeBag: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        baseUrl = "www.example.com"
        urlSessionWrapper = MockURLSessionWrapper()
        networkManager = NetworkManager(urlSessionWrapper: urlSessionWrapper, baseUrl: baseUrl)
        disposeBag = Set()
    }

    func testNetworkManager_OkResponse() throws {
        // Given
        let expectation = XCTestExpectation(description: "Api request")
        let mockedRequest = MockRequest(path: "/path")
        let mockData = """
        {
            "text": "test"
        }
        """.data(using: .utf8)!
        let mockResponse = HTTPURLResponse()
        urlSessionWrapper.dataTaskPublisherWrapperReturn = Just((data: mockData, response: mockResponse))
            .setFailureType(to: URLError.self)
            .eraseToAnyPublisher()

        // When
        let publisher: AnyPublisher<MockResponseData, Error> = networkManager.request(mockedRequest)

        // Then
        publisher.sink(receiveCompletion: { completion in },
                       receiveValue: { object in
            XCTAssertEqual(MockResponseData(text: "test"), object)
            expectation.fulfill()
        })
        .store(in: &disposeBag)

        wait(for: [expectation], timeout: 1.0)
    }

    func testNetworkManager_FailInvalidUrlResponse() throws {
        // Given
        let expectation = XCTestExpectation(description: "Api request")
        let mockedRequest = MockRequest(path: "dsabg uabdisg dsapath")
        urlSessionWrapper.dataTaskPublisherWrapperReturn = Fail(error: URLError(URLError.badURL))
            .eraseToAnyPublisher()

        // When
        let publisher: AnyPublisher<MockResponseData, Error> = networkManager.request(mockedRequest)

        // Then
        publisher.sink(receiveCompletion: { completion in
            if case Subscribers.Completion<any Error>.failure(let error) = completion {
                expectation.fulfill()
            }
        }, receiveValue: { object in

        })
        .store(in: &disposeBag)

        wait(for: [expectation], timeout: 1.0)
    }

    func testNetworkManager_FailParsingResponse() throws {
        // Given
        let expectation = XCTestExpectation(description: "Api request")
        let mockedRequest = MockRequest(path: "/path")
        let mockData = """
        {
            "textasd": "test"
        }
        """.data(using: .utf8)!
        let mockResponse = HTTPURLResponse()
        urlSessionWrapper.dataTaskPublisherWrapperReturn = Just((data: mockData, response: mockResponse))
            .setFailureType(to: URLError.self)
            .eraseToAnyPublisher()

        // When
        let publisher: AnyPublisher<MockResponseData, Error> = networkManager.request(mockedRequest)

        // Then
        publisher.sink(receiveCompletion: { completion in
            if case Subscribers.Completion<any Error>.failure(let error) = completion {
                expectation.fulfill()
            }
        }, receiveValue: { object in

        })
        .store(in: &disposeBag)

        wait(for: [expectation], timeout: 1.0)
    }
}

private struct MockRequest: NetworkRequestable {
    var method: Networking.NetworkMethod = .get
    var path: String
    var headers: [String : String]? = nil
    var body: Data? = nil
}

private struct MockResponseData: Equatable, Codable {
    let text: String
}
