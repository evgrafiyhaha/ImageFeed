import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {

    // MARK: - Private Properties

    private let profileLogoutService = ProfileLogoutService.shared

    private var profileImageServiceObserver: NSObjectProtocol?

    private lazy var logoutButton: UIButton = {
        let buttonImage = UIImage(systemName: "ipad.and.arrow.forward") ?? UIImage()
        let logoutButton = UIButton.systemButton(with: buttonImage, target: self, action: #selector(Self.didTapLogoutButton))
        logoutButton.tintColor = .ypRed
        view.addSubview(logoutButton)
        return logoutButton
    }()
    private lazy var descriptionLabel: UILabel = {
        let descriptionLabel = UILabel()
        descriptionLabel.font = .systemFont(ofSize: 13)
        descriptionLabel.textColor = .white
        view.addSubview(descriptionLabel)
        return descriptionLabel
    }()
    private lazy var userImage: UIImageView = {
        let profileImage = UIImage(named: "Stub.jpeg")
        let userImage = UIImageView(image: profileImage)
        userImage.layer.cornerRadius = 35
        userImage.clipsToBounds = true
        view.addSubview(userImage)
        return userImage
    }()
    private lazy var nameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.font = .systemFont(ofSize: 23)
        nameLabel.textColor = .white
        view.addSubview(nameLabel)
        return nameLabel

    }()
    private lazy var loginNameLabel: UILabel = {
        let loginNameLabel = UILabel()
        loginNameLabel.font = .systemFont(ofSize: 13)
        loginNameLabel.textColor = .ypGray
        view.addSubview(loginNameLabel)
        return loginNameLabel
    }()

    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared

    // MARK: - View Life Cycles

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .ypBlack
        
        setupConstraints()
        updateProfileDetails()
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            }
        updateAvatar()
    }

    // MARK: - Private Methods

    private func logout() {
        profileImageService.removeAvatarURL()
        profileLogoutService.logout()
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        window.rootViewController = SplashViewController()
    }
    
    @objc private func didTapLogoutButton(_ sender: Any) {
        let alert = UIAlertController(title: "Пока, пока!", message: "Вы уверены что хотите выйти?", preferredStyle: .alert)

        let agreeAction = UIAlertAction(title: "Да", style: .default) { [weak self] _ in
            self?.logout()
        }
        let cancelAction = UIAlertAction(title: "Нет", style: .default,handler: nil)

        alert.addAction(agreeAction)
        alert.addAction(cancelAction)

        alert.preferredAction = cancelAction

        present(alert, animated: true, completion: nil)
    }

    private func setupConstraints() {

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

    private func updateProfileDetails() {
        let profile = profileService.profile
        guard let profile else { return }

        self.descriptionLabel.text = profile.bio
        self.nameLabel.text = profile.name
        self.loginNameLabel.text = profile.loginName

    }

    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }

        userImage.kf.indicatorType = .activity
        userImage.kf.setImage(with: url,placeholder: UIImage(named: "Stub.jpeg"))
    }

}
