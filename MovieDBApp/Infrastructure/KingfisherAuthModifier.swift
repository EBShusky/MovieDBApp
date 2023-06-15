import Kingfisher
import Foundation

public struct KingfisherAuthModifier: AsyncImageDownloadRequestModifier {
    public func modified(for request: URLRequest, reportModified: @escaping (URLRequest?) -> Void) {
        var request = request
        request.allHTTPHeaderFields?["Authorization"] = "Bearer \(Keys.movieDBKey.rawValue)"
        reportModified(request)
    }

    public var onDownloadTaskStarted: ((Kingfisher.DownloadTask?) -> Void)?


}
