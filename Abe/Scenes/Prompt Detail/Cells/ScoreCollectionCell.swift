
import Foundation
import UIKit
import SnapKit

class ScoreCollectionCell: UICollectionViewCell {
    
    enum State {
        case userDidReply
        case userDidNotReply
    }
    
    static let reuseIdentifier = "ScoreCollectionCell"
    var containerView: UIView!
    var scoreImageView: UIImageView!
    var percentageBackgroundView: UIView!
    var scorePercentage: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupContainerView()
        setupScoreImageView()
        setupPercentageBackgroundView()
        setupScorePercentage()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with viewModel: ScoreCellViewModel, userDidReply: Bool) {
        self.scoreImageView.image = viewModel.placeholderImage
        self.scorePercentage.text = viewModel.percentage
        self.scoreImageView.isHidden = userDidReply ? true : false
        self.scorePercentage.isHidden = userDidReply ? false : true
        self.percentageBackgroundView.isHidden = userDidReply ? false : true
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
            make.height.width.equalTo(50)
        }
    }
    
    fileprivate func setupPercentageBackgroundView() {
        percentageBackgroundView = UIView()
        percentageBackgroundView.backgroundColor = UIColor.blue
        
        containerView.addSubview(percentageBackgroundView)
        percentageBackgroundView.snp.makeConstraints { (make) in
            make.edges.equalTo(containerView)
            make.height.equalTo(50)
            make.width.equalTo(50)
        }
    }
    
    fileprivate func setupScorePercentage() {
        scorePercentage = UILabel()
        scorePercentage.textColor = UIColor.white
        
        percentageBackgroundView.addSubview(scorePercentage)
        scorePercentage.snp.makeConstraints { (make) in
            make.edges.equalTo(percentageBackgroundView.snp.edges)
            make.center.equalTo(percentageBackgroundView.snp.center)
        }
    }
    
}
