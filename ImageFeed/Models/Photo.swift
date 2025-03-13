import Foundation

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}

extension Photo {
    init(from photoResult: PhotoResult,with dateFormatter: ISO8601DateFormatter) {
        self.id = photoResult.id
        self.size = CGSize(width: photoResult.width, height: photoResult.height)
        self.createdAt = dateFormatter.date(from: photoResult.createdAt)
        self.welcomeDescription = photoResult.description
        self.thumbImageURL = photoResult.urls.thumb
        self.largeImageURL = photoResult.urls.full
        self.isLiked = photoResult.likedByUser
    }
    init (from photo: Photo) {
        self.id = photo.id
        self.size = photo.size
        self.createdAt = photo.createdAt
        self.welcomeDescription = photo.welcomeDescription
        self.thumbImageURL = photo.thumbImageURL
        self.largeImageURL = photo.largeImageURL
        self.isLiked = !photo.isLiked
    }
}
