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
        guard let token = tokenStorage.token else {
            print("[ProfileImageService.fetchProfileImageURL]: AuthError - отсутствует токен")
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }

        assert(Thread.isMainThread)
        if task != nil {
            if lastUsername != username {
                task?.cancel()
            } else {
                print("[ProfileImageService.fetchProfileImageURL]: AuthError - повторный запрос с тем же username (\(username))")
                completion(.failure(AuthServiceError.invalidRequest))
                return
            }
        } else {
            if lastUsername == username {
                print("[ProfileImageService.fetchProfileImageURL]: AuthError - повторный запрос с тем же username (\(username))")
                completion(.failure(AuthServiceError.invalidRequest))
                return
            }
        }
        lastUsername = username
        guard let request = makeImageRequest(token: token, username: username) else {
            print("[ProfileImageService.fetchProfileImageURL]: NetworkError - Ошибка запроса")
            return
        }

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
                    print("[ProfileImageService.fetchProfileImageURL]: NetworkError - \(error.localizedDescription), URL: \(request.url?.absoluteString ?? "Unknown URL")")
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
    
    private func makeImageRequest(token: String,username: String) -> URLRequest? {
        guard let url = URL(string: Constants.baseUsersUrlString + "/\(username)") else {
            print("[ProfileImageService.makeImageRequest]: URLGenerationError - Не удалось создать URL для username (\(username))")
            return nil
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
