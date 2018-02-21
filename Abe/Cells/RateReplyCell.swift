
import Foundation
import UIKit

final class RatingScoreTableCell: UITableViewCell, ValueCell {
    
    // MARK: - Properties
    typealias Value = RatingScoreViewModel
    static var defaultReusableId: String = "RatingScoreTableCell"
    private var containerView: UIView!
    private var mainLabel: UILabel!
    private var iconImageView: UIImageView!
    
    var isSelect: Bool = false {
        didSet {
            self.containerView.backgroundColor = isSelect ? Palette.red.color : UIColor.white
            self.mainLabel.textColor = isSelect ? UIColor.white : UIColor.black
        }
    }
    
    // MARK: - Initialization
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        self.contentView.backgroundColor = UIColor.white
        self.selectionStyle = .none
        setupContainerView()
        setupTitleLabel()
        setupIconImageView()
    }
    
    // MARK: - Configuration
    func configureWith(value: RatingScoreViewModel) {
        mainLabel.text = value.title ?? ""
        iconImageView.image = value.image
        isSelect = value.isSelected
    }
    
}

extension RatingScoreTableCell {
    
    //MARK: View Setup
    private func setupContainerView() {
        containerView = UIView()
        containerView.backgroundColor = Palette.maroon.color
        containerView.layer.cornerRadius = 2.0
        containerView.layer.masksToBounds = true
        containerView.dropShadow()
        
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.top.equalTo(contentView).offset(12)
            make.left.equalTo(contentView).offset(26)
            make.right.equalTo(contentView).offset(-26)
            make.bottom.equalTo(contentView)
            make.height.equalTo(60)
        }
    }
    
    private func setupTitleLabel() {
        mainLabel = UILabel()
        mainLabel.font = FontBook.AvenirMedium.of(size: 14)
        mainLabel.textColor = UIColor.black
        
        containerView.addSubview(mainLabel)
        mainLabel.translatesAutoresizingMaskIntoConstraints = false
        mainLabel.snp.makeConstraints { (make) in
            //make.bottom.equalTo(collectionView.snp.top).offset(-5)
            make.center.equalTo(containerView.snp.center)
            //make.left.equalTo(containerView.snp.left).offset(10)
        }
    }
    
    private func setupIconImageView() {
        iconImageView = UIImageView()
        iconImageView.contentMode = .scaleAspectFit
        
        containerView.addSubview(iconImageView)
        iconImageView.snp.makeConstraints { (make) in
            make.left.equalTo(containerView).offset(20)
            make.centerY.equalTo(containerView)
        }
    }
    
}
