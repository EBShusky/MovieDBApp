import UIKit
import Kingfisher

public class MovieDetailsViewController: UIViewController {

    let movieViewData: MovieDetailsViewData

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

    public init(movie: Movie) {
        self.movieViewData = MovieDetailsViewData(movie: movie)
        super.init(nibName: nil, bundle: nil)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        setupView()
        setupViewData()
    }

    private func setupView() {
        view.addSubview(posterImageView)
        view.addSubview(descriptionTitleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(ratingLabel)
        view.addSubview(releaseDateLabel)

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

    private func setupViewData() {
        self.title = movieViewData.title
        descriptionLabel.text = movieViewData.description
        ratingLabel.text = movieViewData.rating
        releaseDateLabel.text = movieViewData.releaseDateString

        if let urlString = movieViewData.backdropUrl, let url = URL(string: urlString) {
            posterImageView.kf.setImage(with: url, options: [.requestModifier(KingfisherAuthModifier())])
            posterImageView.clipsToBounds = true
        }

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
