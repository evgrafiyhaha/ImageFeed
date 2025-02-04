import Foundation


final class ProfileImageService {
    
    // MARK: - Static Properties
    
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    static let shared = ProfileImageService()
    
    // MARK: - Private Properties
    
    private let urlSession = URLSession.shared
    private let tokenStorage = OAuth2TokenStorage()
    private var task: URLSessionTask?
    private var lastUsername: String?
    private(set) var avatarURL: String?
    
    // MARK: - Initializers
    
    private init() {}
    
    // MARK: - Public Methods
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void){
        guard let token = tokenStorage.token else { return }
        
        assert(Thread.isMainThread)
        if task != nil {
            if lastUsername != username {
                task?.cancel()
            } else {
                completion(.failure(AuthServiceError.invalidRequest))
                return
            }
        } else {
            if lastUsername == username {
                completion(.failure(AuthServiceError.invalidRequest))
                return
            }
        }
        lastUsername = username
        let request = makeImageRequest(token: token, username: username)
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<UserResult,Error>) in
            guard let self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self.avatarURL = data.profileImage.medium
                    completion(.success(data.profileImage.medium))
                    NotificationCenter.default
                        .post(
                            name: ProfileImageService.didChangeNotification,
                            object: self,
                            userInfo: ["URL": self.avatarURL])
                case .failure(let error):
                    print("Ошибка запроса: \(error.localizedDescription)")
                    completion(.failure(error))
                }
                self.task = nil
                self.lastUsername = nil
            }
        }
        self.task = task
        task.resume()
    }
    
    // MARK: - Private Methods
    
    private func makeImageRequest(token: String,username: String) -> URLRequest {
        let url: URL = {
            guard let url = URL(string: "https://api.unsplash.com/users/\(username)") else {
                fatalError("Не удалось инициализировать URL для базового адреса API")
            }
            return url
        }()
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
