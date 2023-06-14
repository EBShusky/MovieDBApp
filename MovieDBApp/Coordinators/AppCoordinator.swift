import UIKit

public enum AppCoordinatorNavigationEvent {
    case list
    case details
}

public protocol AppCoordinatorProtocol {
    func start()
    func process(_ navigationEvent: AppCoordinatorNavigationEvent)
}

public class AppCoordinator: AppCoordinatorProtocol {

    private var window: UIWindow?
    private weak var mainNavigationController: UINavigationController?

    public init() {

    }

    public func start() {
        let window = UIWindow(frame: UIScreen.main.bounds)
        let navigationController = UINavigationController()
        window.rootViewController = navigationController

        self.window = window
        self.mainNavigationController = navigationController
        window.makeKeyAndVisible()
        process(.list)
    }

    public func process(_ navigationEvent: AppCoordinatorNavigationEvent) {
        switch navigationEvent {
        case .list:
            openMovieList()
        case .details:
            openMovieDetails()
        }
    }

    public func openMovieDetails() {

    }

    public func openMovieList() {
        let viewController = MovieListViewController()

        if mainNavigationController?.viewControllers.isEmpty ?? false {
            mainNavigationController?.viewControllers = [viewController]
        } else {
            mainNavigationController?.pushViewController(viewController, animated: true)
        }
    }
}




