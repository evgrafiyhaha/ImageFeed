import Foundation

public protocol ProfileServiceProtocol {
    var profile: Profile? { get }
    func fetchProfile(completion: @escaping (Result<Profile, Error>) -> Void)
}

final class ProfileService: ProfileServiceProtocol {

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
        guard let token = tokenStorage.token else {
            print("[ProfileService.fetchProfile]: AuthError - отсутствует токен")
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }

        assert(Thread.isMainThread)
        if task != nil {
            if lastToken != token {
                task?.cancel()
            } else {
                print("[ProfileService.fetchProfile]: AuthError - повторный запрос с тем же токеном")
                completion(.failure(AuthServiceError.invalidRequest))
                return
            }
        } else {
            if lastToken == token {
                print("[ProfileService.fetchProfile]: AuthError - повторный запрос с тем же токеном")
                completion(.failure(AuthServiceError.invalidRequest))
                return
            }
        }
        lastToken = token
        guard let request = makeprofileRequest(token: token) else {
            print("[ProfileService.fetchProfile]: NetworkError - Ошибка запроса")
            return
        }

        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            guard let self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    let profile = self.convertor(response: data)
                    self.profile = profile

                    completion(.success(profile))
                case .failure(let error):
                    print("[ProfileService.fetchProfile]: NetworkError - \(error.localizedDescription), URL: \(request.url?.absoluteString ?? "Unknown URL")")
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

    private func makeprofileRequest(token: String) -> URLRequest? {
        guard let url = URL(string: Constants.baseProfileUrlString) else {
            print("[ProfileService.makeProfileRequest]: URLGenerationError - Не удалось создать URL")
            return nil
        }

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
