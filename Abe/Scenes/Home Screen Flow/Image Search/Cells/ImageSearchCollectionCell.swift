
import Foundation
import UIKit

class ImageSearchCollectionCell: UICollectionViewCell, ValueCell {

    static var defaultReusableId: String = "ScoreCollectionCell"
    typealias Value = PixaImage
    var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupImageView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureWith(value: PixaImage) {
        if let url = URL(string: value.webformatURL) {
            imageView.kf.indicatorType = .activity
            UIView.animate(withDuration: 0.5, animations: {
                self.imageView.kf.setImage(with: url)
            })
        }
    }
    
    fileprivate func setupImageView() {
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.edges.equalTo(contentView)
        }
    }
    
}
