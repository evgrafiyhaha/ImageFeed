import Foundation

enum Constants {
    static let accessKey = "ECbaL-kOpTa8COyn0xML0JFuRomD3Gl_OMtur6joVqo"
    static let secretKey = "4OuxwYbEw8DUdik4HLaS6KpoFdArEyPiKrG6443ygVI"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURL: URL = {
        guard let url = URL(string: "https://api.unsplash.com") else {
            fatalError("Не удалось инициализировать URL для базового адреса API")
        }
        return url
    }()
}
