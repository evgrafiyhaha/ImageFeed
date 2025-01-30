import Foundation

class OAuth2TokenStorage {

    // MARK: - Public Properties
    var token: String? {
        get {
            return UserDefaults.standard.string(forKey: "OAuth2TokenKey")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "OAuth2TokenKey")
        }
    }
}
