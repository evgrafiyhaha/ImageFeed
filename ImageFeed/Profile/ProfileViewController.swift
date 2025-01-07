import Foundation
import UIKit

final class ProfileViewController: UIViewController {

    // MARK: - Private Properties

    private var logoutButton: UIButton?
    private var descriptionLabel: UILabel?
    private var userImage: UIImageView?
    private var nameLabel: UILabel?
    private var loginNameLabel: UILabel?

    // MARK: - View Life Cycles

    override func viewDidLoad() {
        super.viewDidLoad()

        initViews()
        addSubviews()
        setupConstraints()

    }

    // MARK: - Private Methods

    @objc private func didTapLogoutButton(_ sender: Any) {
        // TODO: - Добавить логику при нажатии на кнопку
    }

    private func initViews() {
        let descriptionLabel = UILabel()
        descriptionLabel.text = "Hello, World!"
        descriptionLabel.font = .systemFont(ofSize: 13)
        descriptionLabel.textColor = .white

        let loginNameLabel = UILabel()
        loginNameLabel.text = "@ekaterina_now"
        loginNameLabel.font = .systemFont(ofSize: 13)
        loginNameLabel.textColor = .ypGray

        let nameLabel = UILabel()
        nameLabel.text = "Екатерина Новикова"
        nameLabel.font = .systemFont(ofSize: 23)
        nameLabel.textColor = .white

        let profileImage = UIImage(named: "profileMockPhoto")
        let userImage = UIImageView(image: profileImage)
        userImage.layer.cornerRadius = 35

        let buttonImage = UIImage(systemName: "ipad.and.arrow.forward") ?? UIImage()
        let logoutButton = UIButton.systemButton(with: buttonImage, target: self, action: #selector(Self.didTapLogoutButton))
        logoutButton.tintColor = .ypRed

        self.logoutButton = logoutButton
        self.descriptionLabel = descriptionLabel
        self.userImage = userImage
        self.nameLabel = nameLabel
        self.loginNameLabel = loginNameLabel
    }

    private func setupConstraints() {
        guard
            let logoutButton,
            let descriptionLabel,
            let userImage,
            let nameLabel,
            let loginNameLabel
        else { return }

        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        userImage.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        loginNameLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            userImage.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 16),
            userImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,constant: 32),
            userImage.widthAnchor.constraint(equalToConstant: 70),
            userImage.heightAnchor.constraint(equalToConstant: 70),
            nameLabel.topAnchor.constraint(equalTo: userImage.bottomAnchor, constant: 8),
            nameLabel.topAnchor.constraint(equalTo: userImage.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: userImage.leadingAnchor),
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            loginNameLabel.leadingAnchor.constraint(equalTo: userImage.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: userImage.leadingAnchor),
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            logoutButton.centerYAnchor.constraint(equalTo: userImage.centerYAnchor),
            logoutButton.widthAnchor.constraint(equalToConstant: 24),
            logoutButton.heightAnchor.constraint(equalToConstant: 24)
        ])
    }

    private func addSubviews() {
        guard
            let logoutButton,
            let descriptionLabel,
            let userImage,
            let nameLabel,
            let loginNameLabel
        else { return }

        view.addSubview(logoutButton)
        view.addSubview(descriptionLabel)
        view.addSubview(userImage)
        view.addSubview(nameLabel)
        view.addSubview(loginNameLabel)
    }
}
