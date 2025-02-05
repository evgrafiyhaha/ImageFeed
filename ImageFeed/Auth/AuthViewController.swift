import UIKit
import ProgressHUD

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}

final class AuthViewController: UIViewController {

    // MARK: - Public Properties

    public var delegate: AuthViewControllerDelegate?

    // MARK: - Private Properties

    private let oauth2Service = OAuth2Service.shared
    private var loginButton: UIButton?
    private var authLogoImageView: UIImageView?

    // MARK: - View Life Cycles

    override func viewDidLoad() {
        super.viewDidLoad()

        initViews()
        addSubviews()
        setupConstraints()
        configureBackButton()
    }

    // MARK: - Private Methods

    private func addSubviews() {
        guard
            let loginButton,
            let authLogoImageView
        else { return }

        view.addSubview(loginButton)
        view.addSubview(authLogoImageView)
    }

    private func setupConstraints() {
        guard
            let loginButton,
            let authLogoImageView
        else { return }

        loginButton.translatesAutoresizingMaskIntoConstraints = false
        authLogoImageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            authLogoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            authLogoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loginButton.heightAnchor.constraint(equalToConstant: 48),
            loginButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -90),
            loginButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            loginButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
        ])
    }

    @objc private func didTapLoginButton(_ sender: Any) {
        let webViewViewController = WebViewViewController()

        webViewViewController.delegate = self
        webViewViewController.modalPresentationStyle = .fullScreen

        self.navigationController?.pushViewController(webViewViewController, animated: true)
    }

    private func initViews() {
        self.view.backgroundColor = .ypBlack

        let authLogoImage = UIImage(named: "auth_screen_logo")
        let authLogoImageView = UIImageView(image: authLogoImage)

        let loginButton = UIButton(type: .system)
        loginButton.setTitle("Войти", for: .normal)
        loginButton.backgroundColor = .white
        loginButton.setTitleColor(.ypBlack, for: .normal)
        loginButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        loginButton.layer.cornerRadius = 16
        loginButton.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)

        self.authLogoImageView = authLogoImageView
        self.loginButton = loginButton
    }

    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor.ypBlack
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        UIBlockingProgressHUD.show()
        oauth2Service.fetchOAuthToken(code: code) { [weak self] result in
            guard let self = self else { return }

            UIBlockingProgressHUD.dismiss()

            switch result {
            case .success(let token):
                print("Получен токен: \(token)")
                self.delegate?.didAuthenticate(self)
            case .failure(let error):
                showAlert(title: "Что-то пошло не так", message: "Не удалось войти в систему")
                print("[AuthViewController.webViewViewController]: OAuthError - Ошибка при получении токена: \(error.localizedDescription)")
            }
            vc.dismiss(animated: true)
        }
    }

    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
}
