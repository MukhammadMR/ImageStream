import UIKit

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet private weak var cellImage: UIImageView!
    @IBOutlet private weak var likeButton: UIButton!
    @IBOutlet private weak var dateLabel: UILabel!
    
    func configure(image: UIImage, isLiked: Bool, date: String) {
            cellImage.image = image
            dateLabel.text = date
            let likeImage = isLiked ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off")
            likeButton.setImage(likeImage, for: .normal)
        }
}
