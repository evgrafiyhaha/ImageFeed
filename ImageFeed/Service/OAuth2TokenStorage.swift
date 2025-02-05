import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    
    // MARK: - Private Properties
    
    private let tokenKey = "OAuth2TokenKey"
    
    // MARK: - Public Properties
    var token: String? {
        get {
            return KeychainWrapper.standard.string(forKey: tokenKey)
        }
        set {
            guard let newValue else {
                KeychainWrapper.standard.removeObject(forKey: tokenKey)
                return
            }
            KeychainWrapper.standard.set(newValue, forKey: tokenKey)
        }
    }
}
