import UIKit

final class SplashViewController: UIViewController {

    // MARK: - Private Properties

    private let tokenStorage = OAuth2TokenStorage()
    private let profileService = ProfileService.shared
    private let showAuthenticationScreenSegueIdentifier = "showAuthenticationScreen"

    private var image: UIImageView?

    // MARK: - View Life Cycles

    override func viewDidLoad() {
        super.viewDidLoad()

        initView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let token = tokenStorage.token {
            fetchProfile(token)
        } else {
            switchToAuthenticationScreen()
        }
    }

    // MARK: - Private Methods

    private func initView() {
        self.view.backgroundColor = .ypBlack

        let image = UIImageView(image: UIImage(named: "splash_screen_logo"))
        image.translatesAutoresizingMaskIntoConstraints = false
        self.image = image
        self.view.addSubview(image)

        NSLayoutConstraint.activate([
            image.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            image.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func switchToAuthenticationScreen() {
        let authViewController = AuthViewController()

        let navController = UINavigationController(rootViewController: authViewController)
        navController.modalPresentationStyle = .fullScreen

        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen

        self.present(navController, animated: true)
    }

    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }

        let tabBarController = TabBarController()

        window.rootViewController = tabBarController
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }

    private func fetchProfile(_ token: String) {
        profileService.fetchProfile() { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let profile):
                ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { _ in }
                self.switchToTabBarController()
            case .failure(let error):
                print("[SplashViewController.fetchProfile]: NetworkError - Ошибка загрузки профиля: \(error.localizedDescription)")
                showAlert(title: "Что-то пошло не так", message: "Не удалось получить профиль")
                break
            }
        }
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true)
    }
}


