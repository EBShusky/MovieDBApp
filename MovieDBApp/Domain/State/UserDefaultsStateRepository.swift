import Combine
import Foundation

public class UserDefaultsFavouritesStateRepository: StateRepositoryProtocol {
    public typealias T = [Int]

    private let codableStorage: CodableKeyedPersistentStorageProtocol
    private let key: String
    private let stateSubject: CurrentValueSubject<T, Never>

    public var publisherState: AnyPublisher<T, Never> {
        return stateSubject.removeDuplicates().eraseToAnyPublisher()
    }

    public var current: T {
        return stateSubject.value
    }

    public init(codableStorage: CodableKeyedPersistentStorageProtocol, key: String) {
        self.codableStorage = codableStorage
        self.key = key

        let initialState: T? = codableStorage.load(key: key)
        self.stateSubject = CurrentValueSubject(initialState ?? [])
    }

    public func update(_ state: T) {
        codableStorage.save(state, key: key)
        stateSubject.send(state)
    }
}
