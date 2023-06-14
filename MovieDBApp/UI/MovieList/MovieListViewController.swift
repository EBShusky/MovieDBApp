import UIKit
import Combine

public class MovieListViewController: UIViewController {

    var disposeBag: Set<AnyCancellable> = Set()

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        let networkManager: AnyPublisher<EnvelopedResponse<[MovieApiData]>, Error> = DIContainer().networkManager.request(ApiCalls.nowPlaying)
            .eraseToAnyPublisher()
        networkManager.sink { completion in
            print(completion)
        } receiveValue: { data in
            print(data)
        }
        .store(in: &disposeBag)

    }
}
