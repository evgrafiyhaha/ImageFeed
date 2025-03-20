import UIKit
import Kingfisher

public protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfilePresenterProtocol? { get set }
    func updateProfileDetails(name: String, login: String, bio: String?)
    func updateAvatar(url: URL?)
}

final class ProfileViewController: UIViewController, ProfileViewControllerProtocol {

    // MARK: - Public Properties

    var presenter: ProfilePresenterProtocol?

    // MARK: - Private Properties

    private lazy var logoutButton: UIButton = {
        let buttonImage = UIImage(systemName: "ipad.and.arrow.forward") ?? UIImage()
        let logoutButton = UIButton.systemButton(with: buttonImage, target: self, action: #selector(Self.didTapLogoutButton))
        logoutButton.accessibilityIdentifier = AccessibilityIdentifiers.profileLogoutButton
        logoutButton.tintColor = .ypRed
        view.addSubview(logoutButton)
        return logoutButton
    }()
    private lazy var descriptionLabel: UILabel = {
        let descriptionLabel = UILabel()
        descriptionLabel.accessibilityIdentifier = AccessibilityIdentifiers.profileDescriptionLabel
        descriptionLabel.font = .systemFont(ofSize: 13)
        descriptionLabel.textColor = .white
        view.addSubview(descriptionLabel)
        return descriptionLabel
    }()
    private lazy var userImage: UIImageView = {
        let profileImage = UIImage(named: "Stub.jpeg")
        let userImage = UIImageView(image: profileImage)
        userImage.accessibilityIdentifier = AccessibilityIdentifiers.profileUserImage
        userImage.layer.cornerRadius = 35
        userImage.clipsToBounds = true
        view.addSubview(userImage)
        return userImage
    }()
    private lazy var nameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.accessibilityIdentifier = AccessibilityIdentifiers.profileNameLabel
        nameLabel.font = .systemFont(ofSize: 23)
        nameLabel.textColor = .white
        view.addSubview(nameLabel)
        return nameLabel
    }()
    private lazy var loginNameLabel: UILabel = {
        let loginNameLabel = UILabel()
        loginNameLabel.accessibilityIdentifier = AccessibilityIdentifiers.profileLoginNameLabel
        loginNameLabel.font = .systemFont(ofSize: 13)
        loginNameLabel.textColor = .ypGray
        view.addSubview(loginNameLabel)
        return loginNameLabel
    }()

    // MARK: - View Life Cycles

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .ypBlack

        setupConstraints()
        presenter?.viewDidLoad()
    }

    // MARK: - Public Methods

    func updateProfileDetails(name: String, login: String, bio: String?) {
        self.descriptionLabel.text = bio
        self.nameLabel.text = name
        self.loginNameLabel.text = login
    }

    func updateAvatar(url: URL?) {
        userImage.kf.indicatorType = .activity
        userImage.kf.setImage(with: url,placeholder: UIImage(named: "Stub.jpeg"))
    }

    func getDisplayedName() -> String? {
        nameLabel.text
    }
    func getDisplayedLogin() -> String? {
        loginNameLabel.text
    }
    func getDisplayedBio() -> String? {
        descriptionLabel.text
    }

    // MARK: - Private Methods

    private func logout() {
        presenter?.logout()
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
}
