import Foundation


final class ImagesListService {

    // MARK: - Static Properties

    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")

    // MARK: - Private Properties

    private(set) var photos: [Photo] = []
    private let tokenStorage = OAuth2TokenStorage()

    private var task: URLSessionTask?
    private var lastLoadedPage: Int = 0

    // MARK: - Public Methods
    
    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        if task?.state == .running {
            print("[ImagesListService.fetchPhotosNextPage]: NetworkError - Повторный запрос")
            return
        }

        guard
            let token = tokenStorage.token,
            let request = makePhotosRequest(token: token)
        else {
            print("[ImagesListService.fetchPhotosNextPage]: NetworkError - Ошибка запроса")
            return
        }

        let task = URLSession.shared.objectTask(for: request) {[weak self] (result: Result<[PhotoResult],Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }

                switch result {
                case .success(let data):
                    let downloadedPhotos = data.map { Photo(from: $0)}

                    self.photos.append(contentsOf: downloadedPhotos)
                    self.lastLoadedPage += 1

                    NotificationCenter.default
                        .post(
                            name: ImagesListService.didChangeNotification,
                            object: self,
                            userInfo: ["Photos": downloadedPhotos])

                case .failure(let error):
                    print("[ImagesListService.fetchPhotosNextPage]: NetworkError - Ошибка запроса: \(error.localizedDescription)")
                }
                self.task = nil
            }
        }
        self.task = task
        task.resume()
    }

    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        assert(Thread.isMainThread)
        guard
            let token = tokenStorage.token,
            let request = makeLikeRequest(token: token,photoId: photoId, isLike: isLike)
        else {
            print("[ImagesListService.fetchPhotosNextPage]: NetworkError - Ошибка запроса")
            return
        }
        let task = URLSession.shared.data(for: request) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success:
                    if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                        let photo = self.photos[index]
                        let newPhoto = Photo(
                            id: photo.id,
                            size: photo.size,
                            createdAt: photo.createdAt,
                            welcomeDescription: photo.welcomeDescription,
                            thumbImageURL: photo.thumbImageURL,
                            largeImageURL: photo.largeImageURL,
                            isLiked: !photo.isLiked
                        )
                        self.photos[index] = newPhoto
                    }
                    completion(.success(()))
                case .failure(let error):
                    print("[ImagesListService.changeLike]: NetworkError - Ошибка запроса: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }

    func removeAllPhotos() {
        photos.removeAll()
    }

    // MARK: - Private Methods

    private func makePhotosRequest(token: String) -> URLRequest? {
        guard let url = URL(string: Constants.basePhotosListString + "?page=\(lastLoadedPage + 1 )&per_page=10") else {
            print("[ImagesListService.makePhotosRequest]: URLGenerationError - Не удалось создать URL")
            return nil
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }

    private func makeLikeRequest(token: String, photoId: String, isLike: Bool) -> URLRequest? {
        guard let url = URL(string: Constants.basePhotosListString + "/\(photoId)/like") else {
            print("[ImagesListService.makeLikeRequest]: URLGenerationError - Не удалось создать URL")
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = isLike ? "POST" : "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }

}


