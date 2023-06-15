import XCTest
import Combine
@testable import MovieDBApp

final class StateRepositoryTests: XCTestCase {

    var sut: AnyStateRepository<String>!
    var disposeBag: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        sut = AnyStateRepository(initialState: "Initial")
        disposeBag = Set()
    }

    func testGet_CurrentValues() {
        // When
        sut.update("asd")

        // Then
        XCTAssertEqual(sut.current, "asd")
    }

    func testEmit_InitialStateAndUpdates() {
        // Given
        var results: [String] = []
        let expectation = XCTestExpectation()

        // When
        
        sut.publisherState.sink(receiveCompletion: { _ in }) { state in
            results.append(state)

            if results.count >= 5 {
                expectation.fulfill()
            }
        }
        .store(in: &disposeBag)
        sut.update("123")
        sut.update("State")
        sut.update("state")
        sut.update("State")
        sut.update("State")

        // Then
        wait(for: [expectation], timeout: 1.0)
    }
}
