import UIKit
@preconcurrency import WebKit

final class WebViewViewController: UIViewController {

    // MARK: - Private Properties

    private var webView: WKWebView?
    var progressView: UIProgressView?

    private var progressObservation: NSKeyValueObservation?

    // MARK: - Public Properties

    weak var delegate: WebViewViewControllerDelegate?

    enum WebViewConstants {
        static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    }

    // MARK: - View Life Cycles

    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        webView?.navigationDelegate = self
        loadAuthView()
        observeProgress()
    }

    // MARK: - Private Methods

    private func initView() {
        self.view.backgroundColor = .systemBackground

        self.progressView = UIProgressView()
        self.webView = WKWebView()
        guard
            let webView,
            let progressView
        else { return }
        progressView.progressTintColor = .ypBlack
        progressView.progressViewStyle = .default

        webView.translatesAutoresizingMaskIntoConstraints = false
        progressView.translatesAutoresizingMaskIntoConstraints = false

        self.view.addSubview(webView)
        self.view.addSubview(progressView)

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
        guard let webView else { return }
        progressObservation = webView.observe(\.estimatedProgress, options: .new) { [weak self] _, change in
            self?.updateProgress()
        }
    }

    private func updateProgress() {
        guard
            let webView,
            let progressView
        else { return }
        progressView.progress = Float(webView.estimatedProgress)
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
    }

    private func loadAuthView() {
        guard
            let webView
        else { return }

        guard var urlComponents = URLComponents(string: WebViewConstants.unsplashAuthorizeURLString) else {
            print("[WebViewViewController.loadAuthView]: URLFormationError - Некорректный URL")
            return
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope)
        ]

        guard let url = urlComponents.url else {
            print("[WebViewViewController.loadAuthView]: URLFormationError - Не удалось сформировать URL из компонентов: \(urlComponents)")
            return
        }

        let request = URLRequest(url: url)
        webView.load(request)
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
        if
            let url = navigationAction.request.url,
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code" })
        {
            return codeItem.value
        } else {
            return nil
        }
    }
}
