import Foundation
import ImageFeed

final class ProfileServiceStub: ProfileServiceProtocol {
    var profile: Profile? 
    func fetchProfile(completion: @escaping (Result<Profile, Error>) -> Void) {}
}
