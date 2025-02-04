import Foundation

struct ProfileResult: Codable {
    let id: String
    let username: String
    let name: String
    let firstName: String
    let lastName: String?
    let bio: String?
    let profileImage: ProfileImage
    let email: String?
}

struct ProfileImage: Codable {
    let small: String
    let medium: String
    let large: String
}
