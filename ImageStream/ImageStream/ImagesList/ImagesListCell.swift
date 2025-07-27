import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet private weak var cellImage: UIImageView!
    @IBOutlet private weak var likeButton: UIButton!
    @IBOutlet private weak var dateLabel: UILabel!
    
    weak var delegate: ImagesListCellDelegate?
    
    func configure(with url: URL?, dateText: String, isLiked: Bool) {
        cellImage.kf.indicatorType = .activity
        cellImage.kf.setImage(with: url, placeholder: UIImage(named: "placeholder"))
        dateLabel.text = dateText
        let likeImage = isLiked ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off")
        likeButton.setImage(likeImage, for: .normal)
    }

    func setIsLiked(_ isLiked: Bool) {
        print("💡 setIsLiked called with: \(isLiked)")
        let likeImage = isLiked ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off")
        likeButton.setImage(likeImage, for: .normal)
    }
    
    func setLikeButtonEnabled(_ isEnabled: Bool) {
        likeButton.isEnabled = isEnabled
    }

    @IBAction private func likeButtonClicked() {
        delegate?.imageListCellDidTapLike(self)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        cellImage.image = nil
    }
}
