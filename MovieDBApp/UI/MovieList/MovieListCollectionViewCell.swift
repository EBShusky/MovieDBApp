import UIKit

public class MovieListCollectionViewCell: UICollectionViewCell {
    public static let identifier = "MovieListCollectionViewCell"

    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .black)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let movieImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    let favouriteButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(titleLabel)
        addSubview(movieImageView)
        addSubview(favouriteButton)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leftAnchor.constraint(equalTo: leftAnchor),
            titleLabel.rightAnchor.constraint(equalTo: rightAnchor),

            movieImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            movieImageView.rightAnchor.constraint(equalTo: rightAnchor),
            movieImageView.leftAnchor.constraint(equalTo: leftAnchor),
            movieImageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    public override func prepareForReuse() {
        super.prepareForReuse()
        movieImageView.kf.cancelDownloadTask()
    }

    public func setup(_ viewData: MovieViewData) {
        titleLabel.text = viewData.title

        if let url = URL(string: viewData.backdropUrl) {
            movieImageView.kf.setImage(with: url, options: [.requestModifier(KingfisherAuthModifier())])
            movieImageView.clipsToBounds = true
        }

        favouriteButton.setImage(UIImage(named: "star.circle"), for: .normal)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
