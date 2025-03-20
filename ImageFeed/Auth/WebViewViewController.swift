import UIKit
@preconcurrency import WebKit

public protocol WebViewViewControllerProtocol: AnyObject {
    var presenter: WebViewPresenterProtocol? { get set }
    func load(request: URLRequest)
    func setProgressValue(_ newValue: Float)
    func setProgressHidden(_ isHidden: Bool)
}

final class WebViewViewController: UIViewController & WebViewViewControllerProtocol {

    // MARK: - Public Properties

    var presenter: WebViewPresenterProtocol?
    weak var delegate: WebViewViewControllerDelegate?

    // MARK: - Private Properties

    private lazy var webView: WKWebView = {
        let webView = WKWebView()
        webView.accessibilityIdentifier = AccessibilityIdentifiers.webViewWebView
        webView.navigationDelegate = self
        view.addSubview(webView)
        return webView
    }()
    private lazy var progressView: UIProgressView = {
        let progressView = UIProgressView()
        progressView.progressTintColor = .ypBlack
        progressView.progressViewStyle = .default
        view.addSubview(progressView)
        return progressView
    }()

    private var progressObservation: NSKeyValueObservation?

    // MARK: - View Life Cycles

    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        presenter?.viewDidLoad()
        observeProgress()
    }

    // MARK: - Public Methods

    func load(request: URLRequest) {
        webView.load(request)
    }

    func setProgressValue(_ newValue: Float) {
        progressView.progress = newValue
    }

    func setProgressHidden(_ isHidden: Bool) {
        progressView.isHidden = isHidden
    }

    // MARK: - Private Methods

    private func initView() {
        self.view.backgroundColor = .systemBackground

        webView.translatesAutoresizingMaskIntoConstraints = false
        progressView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
    }

    private func observeProgress() {
        progressObservation = webView.observe(\.estimatedProgress, options: .new) { [weak self] _, change in
            guard let self else { return }
            self.presenter?.didUpdateProgressValue(self.webView.estimatedProgress)
        }
    }
}

extension WebViewViewController: WKNavigationDelegate{
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let code = code(from: navigationAction) {
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }

    private func code(from navigationAction: WKNavigationAction) -> String? {
        if let url = navigationAction.request.url {
            return presenter?.getCode(from: url)
        }
        return nil
    }
}
