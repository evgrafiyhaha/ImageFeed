import Foundation
import ImageFeed

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var presenter: ProfilePresenterProtocol?
    var profiledetailsUpdated: Bool = false
    var avatarUpdated: Bool = false
    func updateProfileDetails(name: String, login: String, bio: String?) {
        profiledetailsUpdated = true
    }
    func updateAvatar(url: URL?) {
        avatarUpdated = true
    }
}
