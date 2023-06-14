public struct EnvelopedResponse<T: Decodable>: Decodable {
    let page: Int
    let totalPages: Int
    let results: T
}
