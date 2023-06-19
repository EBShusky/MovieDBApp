import Combine

public class InMemoryStateRepository<T: Equatable>: StateRepositoryProtocol {
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
