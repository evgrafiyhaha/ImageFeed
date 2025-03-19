import Foundation

public protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewProtocol? { get set }
    func viewDidLoad()
    func willDisplayCell(at index: Int)
    func didTapLike(at index: Int)
    func getPhotoCount() -> Int
    func getPhoto(at index: Int) -> Photo
}

final class ImagesListPresenter: ImagesListPresenterProtocol {

    // MARK: - Public Properties

    weak var view: ImagesListViewProtocol?

    // MARK: - Private Properties

    private let imagesListService: ImagesListServiceProtocol
    private var imagesServiceObserver: NSObjectProtocol?

    private var photos: [Photo] = []

    // MARK: - Initializers

    init(imagesListService: ImagesListServiceProtocol = ImagesListService()) {
        self.imagesListService = imagesListService
    }

    // MARK: - Public Methods

    func viewDidLoad() {
        imagesServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ImagesListService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.updatePhotos()
            }
        imagesListService.fetchPhotosNextPage()
    }

    func updatePhotos() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        if oldCount != newCount {
            photos = imagesListService.photos
            view?.updateTableViewAnimated(oldCount: oldCount, newCount: newCount)
        }
    }

    func getPhotoCount() -> Int {
        return photos.count
    }

    func getPhoto(at index: Int) -> Photo {
        return photos[index]
    }

    func willDisplayCell(at index: Int) {
        if index + 1 == photos.count {
            imagesListService.fetchPhotosNextPage()
        }
    }

    func didTapLike(at index: Int) {
        let photo = photos[index]

        view?.showLoading()
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self else { return }
            self.view?.hideLoading()
            switch result {
            case .success:
                self.photos[index] = self.imagesListService.photos[index]
                self.view?.reloadCell(at: index)
            case .failure:
                self.view?.showAlert(title: "Что-то пошло не так", message: "Не удалось поставить лайк")
            }
        }
    }

}

