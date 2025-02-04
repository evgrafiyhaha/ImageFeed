import Foundation

final class ProfileService {
    
    // MARK: - Static Properties
    
    static let shared = ProfileService()
    
    // MARK: - Private Properties
    
    private let urlSession = URLSession.shared
    private let tokenStorage = OAuth2TokenStorage()
    
    private(set) var profile: Profile?
    private var task: URLSessionTask?
    private var lastToken: String?
    
    // MARK: - Initializers
    
    private init() {}
    
    // MARK: - Public Methods
    
    func fetchProfile(completion: @escaping (Result<Profile, Error>) -> Void) {
        guard let token = tokenStorage.token else { return }
        
        assert(Thread.isMainThread)
        if task != nil {
            if lastToken != token {
                task?.cancel()
            } else {
                completion(.failure(AuthServiceError.invalidRequest))
                return
            }
        } else {
            if lastToken == token {
                completion(.failure(AuthServiceError.invalidRequest))
                return
            }
        }
        lastToken = token
        let request = makeprofileRequest(token: token)
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            guard let self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    let profile = self.convertor(response: data)
                    self.profile = profile
                    
                    completion(.success(profile))
                case .failure(let error):
                    print("Ошибка запроса: \(error.localizedDescription)")
                    completion(.failure(error))
                }
                self.task = nil
                self.lastToken = nil
            }
        }
        self.task = task
        task.resume()
        
    }
    
    // MARK: - Private Methods
    
    private func makeprofileRequest(token: String) -> URLRequest {
        let url: URL = {
            guard let url = URL(string: "https://api.unsplash.com/me") else {
                fatalError("Не удалось инициализировать URL для базового адреса API")
            }
            return url
        }()
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    private func convertor(response: ProfileResult) -> Profile {
        .init(
            username: response.username,
            name: response.firstName + " " + (response.lastName ?? ""),
            loginName: "@" + response.username,
            bio: response.bio ?? ""
        )
    }
}
