import UIKit
@preconcurrency import WebKit

final class WebViewViewController: UIViewController {

    // MARK: - IB Outlets

    @IBOutlet private var webView: WKWebView!
    @IBOutlet var progressView: UIProgressView!

    // MARK: - Private Properties

    private var progressObservation: NSKeyValueObservation?

    // MARK: - Public Properties

    weak var delegate: WebViewViewControllerDelegate?

    enum WebViewConstants {
        static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    }

    // MARK: - View Life Cycles

    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self

        loadAuthView()
        observeProgress()
    }

    // MARK: - Private Methods

    private func observeProgress() {
        progressObservation = webView.observe(\.estimatedProgress, options: .new) { [weak self] _, change in
            self?.updateProgress()
        }
    }

    private func updateProgress() {
        progressView.progress = Float(webView.estimatedProgress)
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
    }

    private func loadAuthView() {
        guard var urlComponents = URLComponents(string: WebViewConstants.unsplashAuthorizeURLString) else {
            print("Ошибка: Некорректный URL")
            return
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope)
        ]

        guard let url = urlComponents.url else {
            print("Ошибка: Не удалось сформировать URL из компонентов: \(urlComponents)")
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
