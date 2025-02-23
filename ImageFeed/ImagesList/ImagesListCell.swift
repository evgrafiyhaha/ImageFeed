import UIKit

final class ImagesListCell: UITableViewCell {
    
    // MARK: - Static properties
    
    static let reuseIdentifier = "ImagesListCell"
    
    // MARK: - Public Properties
    
    private var cellImage: UIImageView?
    private var likeButton: UIButton?
    private var datelabel: UILabel?
    private var gradientView = GradientView()

    // MARK: - Initializers
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        initViews()
        addSubviews()
        setupConstraints()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        initViews()
        addSubviews()
        setupConstraints()
    }
    
    // MARK: - Private Methods
    
    private func initViews() {
        self.backgroundColor = .ypBlack
        self.contentMode = .center
        self.selectionStyle = .none
        
        
        self.cellImage = UIImageView()
        cellImage?.layer.cornerRadius = 16
        cellImage?.layer.masksToBounds = true
        
        self.datelabel = UILabel()
        datelabel?.textColor = .white
        datelabel?.font = .systemFont(ofSize: 13)
        
        let buttonImage = UIImage(named: "like_button_off")?.withRenderingMode(.alwaysOriginal) ?? UIImage()
        self.likeButton = UIButton.systemButton(with: buttonImage, target: self, action: #selector(Self.didTapLikeButton))
    }
    
    private func addSubviews(){
        guard
            let cellImage,
            let likeButton,
            let datelabel
        else { return }
        
        contentView.addSubview(cellImage)
        contentView.addSubview(likeButton)
        contentView.addSubview(datelabel)
        contentView.addSubview(gradientView)
    }
    
    private func setupConstraints() {
        guard
            let cellImage,
            let likeButton,
            let datelabel
        else { return }
        
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

    func configureCell(image : UIImage,currentDate: String,isLiked: Bool) {
        guard
            let cellImage,
            let likeButton,
            let datelabel
        else { return }

        cellImage.image = image
        datelabel.text = currentDate

        let likeImage = isLiked ? UIImage(named: "like_button_on")?.withRenderingMode(.alwaysOriginal) : UIImage(named: "like_button_off")?.withRenderingMode(.alwaysOriginal)
        likeButton.setImage(likeImage, for: .normal)
    }

    @objc private func didTapLikeButton(_ sender: Any) {
        // TODO: - Добавить логику при нажатии на кнопку
    }
}
