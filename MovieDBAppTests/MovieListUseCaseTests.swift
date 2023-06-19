import XCTest
import Combine
import Networking

@testable import MovieDBApp

final class MovieListUseCaseTests: XCTestCase {

    fileprivate var networkManager: NetworkManagerMock<EnvelopedResponse<[MovieApiData]>>!
    fileprivate var stateRepository: MockMoviesRepository!
    fileprivate var favouritesRepository: MockFavouritesRepository!
    fileprivate var sut: MovieListUseCase!
    fileprivate var disposeBag: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        stateRepository = MockMoviesRepository()
        favouritesRepository = MockFavouritesRepository()
        let typeErasuredRepository = AnyStateRepository(repository: stateRepository)
        let typeErasuredFavouriteRepository = AnyStateRepository(repository: favouritesRepository)
        networkManager = NetworkManagerMock()
        sut = MovieListUseCase(networkManager: networkManager,
                               movieListState: typeErasuredRepository,
                               favouriteMovieState: typeErasuredFavouriteRepository)
        disposeBag = Set()
    }

    func test_ReloadingDataOk() {
        // Given
        let date = Date()
        let expectation = XCTestExpectation(description: "Reload data")
        let loadableExpected = Loadable(item: Pagination(items: [
            Movie.mock(date: date)
        ], currentPage: 1, pages: 10),
                                        state: .loaded)

        let loadableStateExpected = [LoadableState.loading,
                                     LoadableState.loaded]
        var loadableState: [LoadableState] = []
        networkManager.response = EnvelopedResponse(page: 1,
                                                    totalPages: 10,
                                                    results: [
                                                        MovieApiData.mock(date: date)
                                                    ])
        stateRepository.currentInitial = Loadable(item: Pagination(items: [],
                                                                  currentPage: 0,
                                                                  pages: 0),
                                                 state: .initial)

        // When
        stateRepository.updateClosure = { state in
            if loadableState.last != state.state {
                loadableState.append(state.state)
            }

            if loadableState.count == 2 {
                expectation.fulfill()
            }
        }

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

        let loadableStateExpected = [LoadableState.loading,
                                     LoadableState.error]
        var loadableState: [LoadableState] = []
        networkManager.error = ApiError.invalidResponse
        stateRepository.currentInitial = Loadable(item: Pagination(items: [],
                                                                  currentPage: 0,
                                                                  pages: 0),
                                                 state: .initial)

        // When
        stateRepository.updateClosure = { state in
            if loadableState.last != state.state {
                loadableState.append(state.state)
            }

            if loadableState.count == 2 {
                expectation.fulfill()
            }
        }

        sut.reload()

        wait(for: [expectation], timeout: 1.0)

        // Then
        XCTAssertEqual(stateRepository.current, loadableExpected)
        XCTAssertEqual(loadableState, loadableStateExpected)
    }

    func test_NextPageOk() {
        // Given
        let date = Date()
        let expectation = XCTestExpectation(description: "Reload data")
        let loadableExpected = Loadable(item: Pagination(items: [
            Movie.mock(date: date),
            Movie.mock(date: date)
        ], currentPage: 21, pages: 600),
                                        state: .loaded)

        let loadableStateExpected = [LoadableState.loading,
                                     LoadableState.loaded]
        var loadableState: [LoadableState] = []
        networkManager.response = EnvelopedResponse(page: 21,
                                                    totalPages: 600,
                                                    results: [
                                                        MovieApiData.mock(date: date)
                                                    ])
        stateRepository.currentInitial = Loadable(item: Pagination(items: [Movie.mock(date: date)],
                                                                  currentPage: 20,
                                                                  pages: 600),
                                                 state: .loaded)

        sut = MovieListUseCase(networkManager: networkManager,
                               movieListState: AnyStateRepository(repository: stateRepository),
                               favouriteMovieState: AnyStateRepository(repository: favouritesRepository))

        // When
        stateRepository.updateClosure = { state in
            if loadableState.last != state.state {
                loadableState.append(state.state)
            }

            if loadableState.count == 2 {
                expectation.fulfill()
            }
        }

        sut.nextPage()

        wait(for: [expectation], timeout: 1.0)

        // Then
        XCTAssertEqual(stateRepository.updateParamReceived, loadableExpected)
        XCTAssertEqual(loadableState, loadableStateExpected)
    }

    func test_NextPageFail() {
        // Given
        let expectation = XCTestExpectation(description: "Reload data")
        let loadableExpected = Loadable(item: Pagination<Movie>(items: [], currentPage: 20, pages: 600),
                                        state: .error)

        let loadableStateExpected = [LoadableState.loading,
                                     LoadableState.error]
        var loadableState: [LoadableState] = []
        networkManager.error = ApiError.invalidResponse

        stateRepository.currentInitial = Loadable(item: Pagination<Movie>(items: [], currentPage: 20, pages: 600),
                                                 state: .error)

        sut = MovieListUseCase(networkManager: networkManager,
                               movieListState: AnyStateRepository(repository: stateRepository),
                               favouriteMovieState: AnyStateRepository(repository: favouritesRepository))

        // When
        stateRepository.updateClosure = { state in
            loadableState.append(state.state)
            if loadableState.count == 2 {
                expectation.fulfill()
            }
        }

        sut.nextPage()

        wait(for: [expectation], timeout: 1.0)

        // Then
        XCTAssertEqual(stateRepository.current, loadableExpected)
        XCTAssertEqual(loadableState, loadableStateExpected)
    }
}

private class MockMoviesRepository: StateRepositoryProtocol {
    typealias T = Loadable<Pagination<Movie>>

    var publisherStateReturn: AnyPublisher<Loadable<Pagination<Movie>>, Never>!
    var publisherState: AnyPublisher<Loadable<Pagination<Movie>>, Never> {
        return publisherStateReturn
    }

    var currentInitial: Loadable<Pagination<Movie>>!
    var current: Loadable<Pagination<Movie>> {
        return updateParamReceived ?? currentInitial
    }

    var updateClosure: ((Loadable<Pagination<Movie>>) -> ())?
    var updateParamReceived: Loadable<Pagination<Movie>>?
    func update(_ state: Loadable<Pagination<Movie>>) {
        updateClosure?(state)
        updateParamReceived = state
    }
}

private class MockFavouritesRepository: StateRepositoryProtocol {
    typealias T = [Int]

    var publisherState: AnyPublisher<[Int], Never> = [].publisher.eraseToAnyPublisher()
    var current: [Int] = []
    func update(_ state: [Int]) {

    }
}

private extension Movie {
    static func mock(date: Date) -> Movie {
        return Movie(id: 1,
                     overview: "test",
                     backdropUrl: nil,
                     title: "Title1",
                     releaseDate: date,
                     rating: 4.2,
                     isFavourite: false)
    }
}

private extension MovieApiData {
    static func mock(date: Date) -> MovieApiData {
        return MovieApiData(id: 1,
                            overview: "test",
                            backdropUrl: nil,
                            title: "Title1",
                            releaseDate: date,
                            rating: 4.2)
    }
}
