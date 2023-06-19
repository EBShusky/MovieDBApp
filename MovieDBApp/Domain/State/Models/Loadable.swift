public enum LoadableState: Equatable {
    case initial
    case loading
    case loaded
    case error
}

public struct Loadable<T: Equatable>: Equatable {
    var item: T
    var state: LoadableState
}
