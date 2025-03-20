@testable import ImageFeed
import XCTest

final class ProfileViewTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        //given
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController

        //when
        _ = viewController.view

        //then
        XCTAssertTrue(presenter.viewDidLoadCalled) //behaviour verification
    }

    func testUpdateProfileDetails() {
        // given
        let viewController = ProfileViewController()

        // when
        viewController.updateProfileDetails(name: "Test Name", login: "@testuser", bio: "Test Bio")

        // then
        XCTAssertEqual(viewController.getDisplayedName(), "Test Name")
        XCTAssertEqual(viewController.getDisplayedLogin(), "@testuser")
        XCTAssertEqual(viewController.getDisplayedBio(), "Test Bio")
    }
    
    func testPresenterUpdatesAvatar() {
        //given
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfilePresenter()
        viewController.presenter = presenter
        presenter.view = viewController

        //when
        presenter.viewDidLoad()


        //then
        XCTAssertTrue(viewController.avatarUpdated) //behaviour verification
    }

    func testPresenterUpdatesProfileDetails() {
        //given
        let viewController = ProfileViewControllerSpy()
        let profileService = ProfileServiceStub()
        profileService.profile = Profile(username: "username", name: "Test User", loginName: "loginname", bio: "Test Bio")
        let presenter = ProfilePresenter(profileService: profileService)
        viewController.presenter = presenter
        presenter.view = viewController

        //when
        presenter.viewDidLoad()

        //then
        XCTAssertTrue(viewController.profiledetailsUpdated) //behaviour verification
    }

}
