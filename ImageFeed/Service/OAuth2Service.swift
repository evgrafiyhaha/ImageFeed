import Foundation

enum AuthServiceError: Error {
    case invalidRequest
}

final class OAuth2Service {
    
    // MARK: - Static Properties
    
    static let shared = OAuth2Service()
    
    // MARK: - Private Properties
    
    private let tokenStorage = OAuth2TokenStorage()
    private let urlSession = URLSession.shared
    
    private var task: URLSessionTask?
    private var lastCode: String?
    
    // MARK: - Initializers
    
    private init() {}
    
    // MARK: - Public Methods
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        assert(Thread.isMainThread)
        if task != nil {
            if lastCode != code {
                task?.cancel()
            } else {
                print("[OAuth2Service.fetchOAuthToken]: AuthServiceError - Повторный запрос с тем же кодом")
                completion(.failure(AuthServiceError.invalidRequest))
                return
            }
        } else {
            if lastCode == code {
                print("[OAuth2Service.fetchOAuthToken]: AuthServiceError - Повторный запрос с тем же кодом")
                completion(.failure(AuthServiceError.invalidRequest))
                return
            }
        }
        lastCode = code
        let request = makeOAuthTokenRequest(code: code)
        
        let task = URLSession.shared.objectTask(for: request) {[weak self] (result: Result<OAuthTokenResponseBody,Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self?.tokenStorage.token = data.accessToken
                    
                    completion(.success(data.accessToken))
                case .failure(let error):
                    print("[OAuth2Service.fetchOAuthToken]: NetworkError - Ошибка запроса: \(error.localizedDescription)")
                    completion(.failure(error))
                }
                self?.task = nil
                self?.lastCode = nil
            }
        }
        self.task = task
        task.resume()
    }
    
    // MARK: - Private Methods
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest {
        let baseURL: URL = {
            guard let url = URL(string: "https://unsplash.com/oauth/token") else {
                fatalError("[OAuth2Service.makeOAuthTokenRequest]: FatalError - Не удалось инициализировать URL")
            }
            return url
        }()
        
        var urlComponents: URLComponents = {
            guard let components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
                fatalError("[OAuth2Service.makeOAuthTokenRequest]: FatalError - Ошибка инициализации URLComponents")
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
            print("[OAuth2Service.makeOAuthTokenRequest]: URLFormationError - Не удалось сформировать URL из компонентов: \(urlComponents)")
            return URLRequest(url: baseURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
}
