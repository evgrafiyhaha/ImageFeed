import Foundation

enum Constants {
    static let accessKey = "ECbaL-kOpTa8COyn0xML0JFuRomD3Gl_OMtur6joVqo"
    static let secretKey = "4OuxwYbEw8DUdik4HLaS6KpoFdArEyPiKrG6443ygVI"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"

    static let baseAuthUrlString = "https://unsplash.com/oauth/token"
    static let baseUsersUrlString = "https://api.unsplash.com/users"
    static let baseProfileUrlString = "https://api.unsplash.com/me"
    static let basePhotosListString = "https://api.unsplash.com/photos"
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String

    let authBaseURL: String
    let usersURLString: String
    let profileURLString: String
    let photosListURLString: String
    let authURLString: String

    init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, authURLString: String, authBaseURL: String, usersURLString: String, profileURLString: String, photosListURLString: String) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.authBaseURL = authBaseURL
        self.usersURLString = usersURLString
        self.profileURLString = profileURLString
        self.photosListURLString = photosListURLString
        self.authURLString = authURLString
    }

    static var standard: AuthConfiguration {
        AuthConfiguration(accessKey: Constants.accessKey,
                          secretKey: Constants.secretKey,
                          redirectURI: Constants.redirectURI,
                          accessScope: Constants.accessScope,
                          authURLString: Constants.unsplashAuthorizeURLString,
                          authBaseURL: Constants.baseAuthUrlString,
                          usersURLString: Constants.baseUsersUrlString,
                          profileURLString: Constants.baseUsersUrlString,
                          photosListURLString: Constants.basePhotosListString)
    }
}
