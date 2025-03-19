@testable import ImageFeed
import XCTest

final class ImageListViewTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        //given
        let viewController = ImagesListViewController()
        let presenter = ImagesListPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController

        //when
        _ = viewController.view

        //then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }

    func testViewControllerFetchesPhotos() {
        // Given
        let viewController = ImagesListViewController()
        let imagesListServiceSpy = ImagesListServiceSpy()
        let presenter = ImagesListPresenter(imagesListService: imagesListServiceSpy)
        viewController.presenter = presenter
        presenter.view = viewController

        // When
        _ = viewController.view

        // Then
        XCTAssertTrue(imagesListServiceSpy.fetchPhotosCalled)
    }

    func testPresenterChangesLike() {
        // Given
        let imagesListServiceSpy = ImagesListServiceSpy()
        let presenter = ImagesListPresenter(imagesListService: imagesListServiceSpy)

        imagesListServiceSpy.photos.append(Photo())
        presenter.updatePhotos()

        // When
        presenter.didTapLike(at: 0)

        // Then
        XCTAssertTrue(imagesListServiceSpy.changeLikeCalled)
    }

    func testNumberOfRowsInSection() {
        // given
        let viewController = ImagesListViewController()
        let presenter = ImagesListPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        let expectedCount = 10

        // when
        viewController.loadViewIfNeeded()
        let numberOfRows = viewController.getNumberOfRowsInSection(0)

        // Then
        XCTAssertEqual(numberOfRows, expectedCount)

    }

}

