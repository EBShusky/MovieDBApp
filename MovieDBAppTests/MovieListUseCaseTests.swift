import XCTest
import Combine
import Networking

@testable import MovieDBApp

final class MovieListUseCaseTests: XCTestCase {

    var networkManager: NetworkManagerMock<EnvelopedResponse<[MovieApiData]>>!
    var stateRepository: AnyStateRepository<Loadable<Pagination<Movie>>>!
    var sut: MovieListUseCase!
    var disposeBag: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        stateRepository = AnyStateRepository(initialState: Loadable(item: Pagination(items: [],
                                                                                     currentPage: 0,
                                                                                     pages: 0),
                                                                    state: .initial))
        networkManager = NetworkManagerMock()
        sut = MovieListUseCase(networkManager: networkManager,
                               movieListState: stateRepository)
        disposeBag = Set()
    }

    func test_ReloadingDataOk() {
        // Given
        let expectation = XCTestExpectation(description: "Reload data")
        let loadableExpected = Loadable(item: Pagination(items: [
            Movie(id: 1,
                  overview: "test",
                  backdropUrl: nil,
                  title: "Title1",
                  isFavourite: false)
        ], currentPage: 1, pages: 10),
                                        state: .loaded)

        let loadableStateExpected = [LoadableState.initial,
                                     LoadableState.loading,
                                     LoadableState.loaded]
        var loadableState: [LoadableState] = []
        networkManager.response = EnvelopedResponse(page: 1,
                                                    totalPages: 10,
                                                    results: [
                                                        MovieApiData(id: 1,
                                                                     overview: "test",
                                                                     backdropUrl: nil,
                                                                     title: "Title1")
                                                    ])

        // When
        stateRepository.publisherState
            .map(\.state)
            .removeDuplicates()
            .sink(receiveCompletion: {_ in }) { state in
                loadableState.append(state)
                if state == .loaded {
                    expectation.fulfill()
                }
            }
            .store(in: &disposeBag)

        sut.reload()

        wait(for: [expectation], timeout: 1.0)

        // Then
        XCTAssertEqual(stateRepository.current, loadableExpected)
        XCTAssertEqual(loadableState, loadableStateExpected)
    }

    func test_ReloadingDataFail() {
        // Given
        let expectation = XCTestExpectation(description: "Reload data")
        let loadableExpected = Loadable(item: Pagination<Movie>(items: [], currentPage: 0, pages: 0),
                                        state: .error)

        let loadableStateExpected = [LoadableState.initial,
                                     LoadableState.loading,
                                     LoadableState.error]
        var loadableState: [LoadableState] = []
        networkManager.error = ApiError.invalidResponse

        // When
        stateRepository.publisherState
            .map(\.state)
            .removeDuplicates()
            .sink(receiveCompletion: {_ in }) { state in
                loadableState.append(state)
                if state == .error {
                    expectation.fulfill()
                }
            }
            .store(in: &disposeBag)

        sut.reload()

        wait(for: [expectation], timeout: 1.0)

        // Then
        XCTAssertEqual(stateRepository.current, loadableExpected)
        XCTAssertEqual(loadableState, loadableStateExpected)
    }

    func test_NextPageOk() {
        // Given
        let expectation = XCTestExpectation(description: "Reload data")
        let loadableExpected = Loadable(item: Pagination(items: [
            Movie(id: 1,
                  overview: "test",
                  backdropUrl: nil,
                  title: "Title1",
                  isFavourite: false)
        ], currentPage: 21, pages: 600),
                                        state: .loaded)

        let loadableStateExpected = [LoadableState.loaded,
                                     LoadableState.loading,
                                     LoadableState.loaded]
        var loadableState: [LoadableState] = []
        networkManager.response = EnvelopedResponse(page: 21,
                                                    totalPages: 600,
                                                    results: [
                                                        MovieApiData(id: 1,
                                                                     overview: "test",
                                                                     backdropUrl: nil,
                                                                     title: "Title1")
                                                    ])
        stateRepository = AnyStateRepository(initialState: Loadable(item: Pagination(items: [],
                                                                                     currentPage: 20,
                                                                                     pages: 600),
                                                                    state: .loaded))
        sut = MovieListUseCase(networkManager: networkManager,
                               movieListState: stateRepository)

        // When
        stateRepository.publisherState
            .map(\.state)
            .removeDuplicates()
            .sink(receiveCompletion: {_ in }) { state in
                loadableState.append(state)
                if loadableState.count == 3 {
                    expectation.fulfill()
                }
            }
            .store(in: &disposeBag)

        sut.nextPage()

        wait(for: [expectation], timeout: 1.0)

        // Then
        XCTAssertEqual(stateRepository.current, loadableExpected)
        XCTAssertEqual(loadableState, loadableStateExpected)
    }

    func test_NextPageFail() {
        // Given
        let expectation = XCTestExpectation(description: "Reload data")
        let loadableExpected = Loadable(item: Pagination<Movie>(items: [], currentPage: 20, pages: 600),
                                        state: .error)

        let loadableStateExpected = [LoadableState.loaded,
                                     LoadableState.loading,
                                     LoadableState.error]
        var loadableState: [LoadableState] = []
        networkManager.error = ApiError.invalidResponse

        stateRepository = AnyStateRepository(initialState: Loadable(item: Pagination(items: [],
                                                                                     currentPage: 20,
                                                                                     pages: 600),
                                                                    state: .loaded))
        sut = MovieListUseCase(networkManager: networkManager,
                               movieListState: stateRepository)

        // When
        stateRepository.publisherState
            .map(\.state)
            .removeDuplicates()
            .sink(receiveCompletion: {_ in }) { state in
                loadableState.append(state)
                if loadableState.count == 3 {
                    expectation.fulfill()
                }
            }
            .store(in: &disposeBag)

        sut.nextPage()

        wait(for: [expectation], timeout: 1.0)

        // Then
        XCTAssertEqual(stateRepository.current, loadableExpected)
        XCTAssertEqual(loadableState, loadableStateExpected)
    }
}
