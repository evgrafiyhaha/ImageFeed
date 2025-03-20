import Foundation
import ImageFeed

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    weak var view: ImagesListViewProtocol?
    
    var viewDidLoadCalled = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func willDisplayCell(at index: Int) {}
    
    func didTapLike(at index: Int) {}
    
    func getPhotoCount() -> Int {
        return 10
    }
    
    func getPhoto(at index: Int) -> Photo {
        return Photo()
    }
}
