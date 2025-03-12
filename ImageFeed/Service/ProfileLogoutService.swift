import Foundation
import WebKit

final class ProfileLogoutService {
    
    // MARK: - Static Properties
    
    static let shared = ProfileLogoutService()
    
    // MARK: - Private Properties
    
    private let oAuth2TokenStorage = OAuth2TokenStorage()
    private let imagesListService = ImagesListService()
    
    // MARK: - Initializers
    
    private init() { }
    
    // MARK: - Public Methods
    
    func logout() {
        cleanCookies()
        cleanToken()
        cleanPictures()
    }
    
    // MARK: - Private Methods
    
    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
    
    private func cleanToken() {
        oAuth2TokenStorage.token = nil
    }
    
    private func cleanPictures() {
        imagesListService.removeAllPhotos()
    }
}

