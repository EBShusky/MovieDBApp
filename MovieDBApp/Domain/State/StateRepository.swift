import Combine

public protocol StateRepositoryProtocol where T: Equatable {
    associatedtype T

    var publisherState: AnyPublisher<T, Never> { get }
    var current: T { get }
    func update(_ state: T)
}

public class AnyStateRepository<T: Equatable>: StateRepositoryProtocol {
    private let currentClosure: () -> (T)
    private let publisherStateClosure: () -> (AnyPublisher<T, Never>)
    private let updateClosure: (T) -> ()

    public var publisherState: AnyPublisher<T, Never> {
        return publisherStateClosure()
    }

    public var current: T {
        return currentClosure()
    }

    public init<Base: StateRepositoryProtocol>(repository: Base) where Base.T == T {
        currentClosure = {
            repository.current
        }

        publisherStateClosure = {
            repository.publisherState
        }

        updateClosure = { state in
            repository.update(state)
        }
    }

    public func update(_ state: T) {
        updateClosure(state)
    }
}
