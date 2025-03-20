import XCTest
@testable import ImageFeed

final class Image_FeedUITests: UITestCase {

    func testAuth() throws {
        app.buttons[AccessibilityIdentifiers.authLoginButton].tap()

        let webView = app.webViews[AccessibilityIdentifiers.webViewWebView]

        XCTAssertTrue(webView.waitForExistence(timeout: 5))

        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))

        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))

        loginTextField.tap()
        loginTextField.typeText("artemiytolkishevsky@yandex.ru")
        webView.swipeUp()

        passwordTextField.tap()
        passwordTextField.typeText("12345678")
        webView.swipeUp()

        webView.buttons["Login"].tap()

        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }

    func testFeed() throws {

        let tablesQuery = app.tables
        sleep(2)
        app.swipeUp()
        sleep(2)
        app.swipeDown()
        sleep(2)

        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
        let likeButton = cell.buttons[AccessibilityIdentifiers.imagesListCellLikeButton]
        likeButton.tap()
        sleep(3)

        likeButton.tap()
        sleep(3)

        cell.tap()
        sleep(3)
        let image = app.scrollViews.images.element(boundBy: 0)
        image.pinch(withScale: 3, velocity: 1)
        image.pinch(withScale: 0.5, velocity: -1)

        app.buttons[AccessibilityIdentifiers.singleImageBackButton].tap()

    }

    func testProfile() throws {
        sleep(3)
        app.tabBars.buttons.element(boundBy: 1).tap()

        sleep(1)
        XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.profileDescriptionLabel].exists)
        XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.profileNameLabel].exists)
        XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.profileLoginNameLabel].exists)

        app.buttons[AccessibilityIdentifiers.profileLogoutButton].tap()
        sleep(2)
        app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Да"].tap()
        sleep(2)

        XCTAssertTrue(app.buttons[AccessibilityIdentifiers.authLoginButton].exists)
    }
}
