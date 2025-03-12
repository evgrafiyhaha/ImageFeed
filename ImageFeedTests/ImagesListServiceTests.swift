//
//  ImageFeedTests.swift
//  ImageFeedTests
//
//  Created by Артемий Толкишевский on 26.12.2024.
//

import XCTest
@testable import ImageFeed

final class ImagesListServiceTests: XCTestCase {
    func testFetchPhotos() {
        let service = ImagesListService()

        let expectation = self.expectation(description: "Wait for Notification")
        NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main) { _ in
                expectation.fulfill()
            }

        service.fetchPhotosNextPage()

        wait(for: [expectation], timeout: 10)

        XCTAssertEqual(service.photos.count, 10)
    }
}
