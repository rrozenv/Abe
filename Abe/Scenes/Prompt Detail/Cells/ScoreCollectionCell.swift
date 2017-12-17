
import Foundation
import UIKit
import SnapKit

class ScoreCollectionCell: UICollectionViewCell {
    
    static let reuseIdentifier = "ScoreCollectionCell"
    var containerView: UIView!
    var scoreImageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupContainerView()
        setupScoreImageView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupContainerView() {
        containerView = UIView()
        containerView.backgroundColor = UIColor.orange
        
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.edges.equalTo(contentView)
        }
    }
    
    fileprivate func setupScoreImageView() {
        scoreImageView = UIImageView()

        containerView.addSubview(scoreImageView)
        scoreImageView.snp.makeConstraints { (make) in
            make.edges.equalTo(containerView)
            make.height.width.equalTo(25)
        }
    }
    
}
