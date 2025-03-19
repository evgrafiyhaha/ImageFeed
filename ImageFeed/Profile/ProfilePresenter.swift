import Foundation

public protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func logout()
}

final class ProfilePresenter: ProfilePresenterProtocol {

    // MARK: - Public Properties

    weak var view: ProfileViewControllerProtocol?

    // MARK: - Private Properties

    private let profileService: ProfileServiceProtocol
    private let profileImageService: ProfileImageService
    private let profileLogoutService: ProfileLogoutService
    private var profileImageServiceObserver: NSObjectProtocol?

    // MARK: - Initializers

    init(
        profileService: ProfileServiceProtocol = ProfileService.shared,
        profileImageService: ProfileImageService = .shared,
        profileLogoutService: ProfileLogoutService = .shared) {
            self.profileService = profileService
            self.profileImageService = profileImageService
            self.profileLogoutService = profileLogoutService
        }

    // MARK: - Public Methods
    
    func viewDidLoad() {
        updateProfileDetails()
        observeProfileImageChanges()
    }

    func logout() {
        profileImageService.removeAvatarURL()
        profileLogoutService.logout()
    }

    // MARK: - Private Methods

    private func updateProfileDetails() {
        guard let profile = profileService.profile else { return }
        view?.updateProfileDetails(name: profile.name, login: profile.loginName, bio: profile.bio)
    }

    private func observeProfileImageChanges() {
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateAvatar()
        }
        updateAvatar()
    }

    private func updateAvatar() {
        let url = profileImageService.avatarURL.flatMap { URL(string: $0) }
        view?.updateAvatar(url: url)
    }
}
