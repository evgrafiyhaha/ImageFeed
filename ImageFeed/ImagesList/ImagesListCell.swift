import UIKit

final class ImagesListCell: UITableViewCell {

    // MARK: - Static properties

    static let reuseIdentifier = "ImagesListCell"

    // MARK: - @IBOutlet properties

    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var datelabel: UILabel!

    
}
