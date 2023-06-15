public struct Pagination<T: Equatable>: Equatable {
    let items: [T]
    let currentPage: Int
    let pages: Int

//    func consume(_ page: Pagination<T>) {
//        self
//    }
}
