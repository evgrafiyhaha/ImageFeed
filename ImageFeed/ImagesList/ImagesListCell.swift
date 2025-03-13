import UIKit

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    
    // MARK: - Static properties
    
    static let reuseIdentifier = "ImagesListCell"
    
    // MARK: - Public Properties
    
    weak var delegate: ImagesListCellDelegate?
    
    // MARK: - Private Properties
    
    private lazy var cellImage: UIImageView = {
        let cellImage = UIImageView()
        cellImage.layer.cornerRadius = 16
        cellImage.layer.masksToBounds = true
        contentView.addSubview(cellImage)
        return cellImage
    }()
    private lazy var likeButton: UIButton = {
        let buttonImage = UIImage(named: "like_button_off")?.withRenderingMode(.alwaysOriginal) ?? UIImage()
        let likeButton = UIButton.systemButton(with: buttonImage, target: self, action: #selector(Self.didTapLikeButton))
        contentView.addSubview(likeButton)
        return likeButton
    }()
    private lazy var datelabel: UILabel = {
        let datelabel = UILabel()
        datelabel.textColor = .white
        datelabel.font = .systemFont(ofSize: 13)
        contentView.addSubview(datelabel)
        return datelabel
    }()
    private var gradientView = GradientView()
    
    // MARK: - Initializers
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        initViews()
        setupConstraints()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        initViews()
        setupConstraints()
    }
    
    // MARK: - Overrides Methods
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        cellImage.kf.cancelDownloadTask()
    }
    
    // MARK: - Public Methods
    
    func configureCell(dateFormatter: DateFormatter,photo: Photo) {
        guard
            let url = URL(string: photo.thumbImageURL)
        else { return }
        
        cellImage.kf.indicatorType = .activity
        cellImage.kf.setImage(with: url,placeholder: UIImage(named: "PhotoStub"))
        if let createdAt = photo.createdAt {
            datelabel.text = dateFormatter.string(from: createdAt)
        }
        
        let likeImage = photo.isLiked ? UIImage(named: "like_button_on")?.withRenderingMode(.alwaysOriginal) : UIImage(named: "like_button_off")?.withRenderingMode(.alwaysOriginal)
        likeButton.setImage(likeImage, for: .normal)
    }
    
    // MARK: - Private Methods
    
    private func initViews() {
        self.backgroundColor = .ypBlack
        self.contentMode = .center
        self.selectionStyle = .none
        contentView.addSubview(gradientView)
    }
    
    private func setupConstraints() {
        
        cellImage.translatesAutoresizingMaskIntoConstraints = false
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        datelabel.translatesAutoresizingMaskIntoConstraints = false
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            cellImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cellImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cellImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            cellImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            likeButton.heightAnchor.constraint(equalToConstant: 44),
            likeButton.widthAnchor.constraint(equalToConstant: 44),
            likeButton.topAnchor.constraint(equalTo: cellImage.topAnchor),
            likeButton.trailingAnchor.constraint(equalTo: cellImage.trailingAnchor),
            
            datelabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            datelabel.leadingAnchor.constraint(equalTo: cellImage.leadingAnchor, constant: 8),
            
            gradientView.bottomAnchor.constraint(equalTo: cellImage.bottomAnchor),
            gradientView.trailingAnchor.constraint(equalTo: cellImage.trailingAnchor),
            gradientView.leadingAnchor.constraint(equalTo: cellImage.leadingAnchor),
            gradientView.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    @objc private func didTapLikeButton(_ sender: Any) {
        delegate?.imageListCellDidTapLike(self)
    }
}
