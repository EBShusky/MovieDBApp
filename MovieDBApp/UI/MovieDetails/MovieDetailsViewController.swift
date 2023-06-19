import UIKit
import Kingfisher
import Combine

public class MovieDetailsViewController: UIViewController {

    private let movieDetailsState: AnyStateRepository<Movie>
    private let favouriteMovieUseCase: FavouriteMovieUseCaseProtocol
    private var disposeBag = Set<AnyCancellable>()

    lazy var posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    lazy var descriptionTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.text = "Description:"
        return label
    }()

    lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13)
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        return label
    }()

    lazy var ratingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 24, weight: .bold)
        return label
    }()

    lazy var releaseDateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13)
        return label
    }()

    lazy var favouriteButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(named: "star.circle"), style: .plain, target: self, action: #selector(tappedFavourite))
        return button
    }()

    public init(movieDetailsState: AnyStateRepository<Movie>,
                favouriteMovieUseCase: FavouriteMovieUseCaseProtocol) {
        self.movieDetailsState = movieDetailsState
        self.favouriteMovieUseCase = favouriteMovieUseCase
        super.init(nibName: nil, bundle: nil)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        setupView()
        setupStateUpdates()
    }

    private func setupView() {
        view.addSubview(posterImageView)
        view.addSubview(descriptionTitleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(ratingLabel)
        view.addSubview(releaseDateLabel)

        navigationItem.rightBarButtonItem = favouriteButton
        navigationController?.navigationItem.rightBarButtonItem = favouriteButton

        NSLayoutConstraint.activate([
            posterImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            posterImageView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            posterImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            posterImageView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.75),

            descriptionTitleLabel.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: 16),
            descriptionTitleLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            descriptionTitleLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),

            descriptionLabel.topAnchor.constraint(equalTo: descriptionTitleLabel.bottomAnchor, constant: 16),
            descriptionLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            descriptionLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: 16),

            ratingLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            ratingLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),

            releaseDateLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            releaseDateLabel.firstBaselineAnchor.constraint(equalTo: descriptionTitleLabel.firstBaselineAnchor)
        ])
    }

    private func setupStateUpdates() {
        movieDetailsState.publisherState
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] state in
                self?.updateView(viewData: MovieDetailsViewData(movie: state))
            })
            .store(in: &disposeBag)
    }

    private func updateView(viewData: MovieDetailsViewData) {
        self.title = viewData.title
        descriptionLabel.text = viewData.description
        ratingLabel.text = viewData.rating
        releaseDateLabel.text = viewData.releaseDateString

        if let urlString = viewData.backdropUrl, let url = URL(string: urlString) {
            posterImageView.kf.setImage(with: url, options: [.requestModifier(KingfisherAuthModifier())])
            posterImageView.clipsToBounds = true
        }

        favouriteButton.image = viewData.isFavourite ? UIImage(systemName: "star.circle") : UIImage(systemName: "star.circle.fill")
    }

    @objc
    private func tappedFavourite() {
        let movie = movieDetailsState.current
        if movieDetailsState.current.isFavourite {
            favouriteMovieUseCase.unfavouriteMovie(movie: movie)
        } else {
            favouriteMovieUseCase.favouriteMovie(movie: movie)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
