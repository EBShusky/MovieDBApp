import Combine

public protocol StateRepositoryProtocol where T: Equatable {
    associatedtype T

    var publisherState: AnyPublisher<T, Never> { get }
    var current: T { get }
    func update(_ state: T)
}

public class AnyStateRepository<T: Equatable>: StateRepositoryProtocol {
    private let stateSubject: CurrentValueSubject<T, Never>
    public var publisherState: AnyPublisher<T, Never> {
        return stateSubject.removeDuplicates().eraseToAnyPublisher()
    }

    public var current: T {
        return stateSubject.value
    }

    public init(initialState: T) {
        self.stateSubject = CurrentValueSubject(initialState)
    }

    public func update(_ state: T) {
        stateSubject.send(state)
    }
}
