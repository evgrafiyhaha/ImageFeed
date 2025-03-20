import Foundation
import ImageFeed

final class ImagesListServiceSpy: ImagesListServiceProtocol {
    var photos: [Photo] = []
    var fetchPhotosCalled = false
    var changeLikeCalled = false
    
    func fetchPhotosNextPage() {
        fetchPhotosCalled = true
    }
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, any Error>) -> Void) {
        changeLikeCalled = true
    }
}
