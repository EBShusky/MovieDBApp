import UIKit

public class MovieListCollectionViewCell: UICollectionViewCell {
    public static let identifier = "MovieListCollectionViewCell"

    var favouriteTappedClosure: (() -> ())?

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
        button.addTarget(self, action: #selector(favouriteTapped), for: .touchUpInside)
        return button
    }()

    let triangleView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.transform = CGAffineTransform(rotationAngle: CGFloat.pi/4)
        return view
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(titleLabel)
        addSubview(movieImageView)
        addSubview(triangleView)
        addSubview(favouriteButton)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leftAnchor.constraint(equalTo: leftAnchor),
            titleLabel.rightAnchor.constraint(equalTo: rightAnchor),

            movieImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            movieImageView.rightAnchor.constraint(equalTo: rightAnchor),
            movieImageView.leftAnchor.constraint(equalTo: leftAnchor),
            movieImageView.bottomAnchor.constraint(equalTo: bottomAnchor),

            triangleView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 50),
            triangleView.rightAnchor.constraint(equalTo: rightAnchor, constant: 50),
            triangleView.widthAnchor.constraint(equalToConstant: 100),
            triangleView.heightAnchor.constraint(equalToConstant: 100),

            favouriteButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            favouriteButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -8),
        ])
    }

    public override func prepareForReuse() {
        super.prepareForReuse()
        movieImageView.kf.cancelDownloadTask()
    }

    public func setup(_ viewData: MovieViewData) {
        titleLabel.text = viewData.title

        if let urlString = viewData.backdropUrl, let url = URL(string: urlString) {
            movieImageView.kf.setImage(with: url, options: [.requestModifier(KingfisherAuthModifier())])
            movieImageView.clipsToBounds = true
        }

        favouriteButton.setImage(viewData.isFavourite ? UIImage(systemName: "star.circle") : UIImage(systemName: "star.circle.fill"),
                                 for: .normal)
    }

    @objc private func favouriteTapped() {
        favouriteTappedClosure?()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private class TriangleView : UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func draw(_ rect: CGRect) {

        guard let context = UIGraphicsGetCurrentContext() else { return }

        context.beginPath()
        context.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        context.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        context.addLine(to: CGPoint(x: (rect.maxX / 2.0), y: rect.minY))
        context.closePath()

        context.setFillColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 0.60)
        context.fillPath()
    }
}
