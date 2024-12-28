import UIKit

final class ImagesListCell: UITableViewCell {
    
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var datelabel: UILabel!
    
    static let reuseIdentifier = "ImagesListCell"
    
}
