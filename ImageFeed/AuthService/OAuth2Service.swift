import Foundation

final class OAuth2Service {

    // MARK: - Static Properties

    static let shared = OAuth2Service()

    // MARK: - Private Properties

    private let tokenStorage = OAuth2TokenStorage()

    // MARK: - Initializers

    private init() {}

    // MARK: - Public Methods

    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        let request = makeOAuthTokenRequest(code: code)

        let task = URLSession.shared.data(for: request) { result in
            switch result {
            case .success(let data):
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                do {
                    let response = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                    self.tokenStorage.token = response.accessToken

                    completion(.success(response.accessToken))
                } catch {
                    print("Ошибка декодирования ответа: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            case .failure(let error):
                print("Ошибка запроса: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        task.resume()
    }

    // MARK: - Private Methods

    private func makeOAuthTokenRequest(code: String) -> URLRequest {
        let baseURL: URL = {
            guard let url = URL(string: "https://unsplash.com/oauth/token") else {
                fatalError("Не удалось инициализировать URL для базового адреса API")
            }
            return url
        }()
        
        var urlComponents: URLComponents = {
            guard let components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
                fatalError("Ошибка инициализации URLComponents")
            }
            return components
        }()

        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]

        guard let url = urlComponents.url else {
            print("Ошибка: Не удалось сформировать URL из компонентов: \(urlComponents)")
            return URLRequest(url: baseURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
}
