public struct Pagination<T: Equatable>: Equatable {
    public var items: [T]
    public var currentPage: Int
    public var pages: Int

    public mutating func consume(_ page: Pagination<T>) {
        self.items.append(contentsOf: page.items)
        self.currentPage = page.currentPage
        self.pages = page.pages
    }
}
