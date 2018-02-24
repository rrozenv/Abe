
import Foundation
import UIKit

final class SettingCell: UITableViewCell, ValueCell {
    
    // MARK: - Properties
    typealias Value = Setting
    static var defaultReusableId: String = "SettingCell"
    private var containerView: UIView!
    private var mainLabel: UILabel!
    private var iconImageView: UIImageView!
    
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
        setupIconImageView()
        setupTitleLabel()
    }
    
    // MARK: - Configuration
    func configureWith(value: Setting) {
        //updateImageViewContraintsFor(settingType: value.type)
        mainLabel.text = value.type.rawValue
        //iconImageView.image = value.iconImage
    }
    
}

extension SettingCell {
    
    //MARK: View Setup
    private func setupContainerView() {
        containerView = UIView()
        containerView.backgroundColor = UIColor.white
        
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.edges.equalTo(contentView)
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
            make.centerY.equalTo(containerView)
            make.left.equalTo(iconImageView.snp.right).offset(12)
        }
    }
    
    private func setupIconImageView() {
        iconImageView = UIImageView()
        iconImageView.contentMode = .scaleAspectFill
        
        containerView.addSubview(iconImageView)
        iconImageView.snp.makeConstraints { (make) in
            make.left.equalTo(containerView).offset(20)
            make.width.height.equalTo(20)
            make.centerY.equalTo(containerView)
        }
    }
    
    private func updateImageViewContraintsFor(settingType: SettingType) {
        switch settingType {
        case .feedback:
            iconImageView.snp.updateConstraints { (make) in
                make.width.equalTo(11)
                make.height.equalTo(11)
            }
        case .share:
            iconImageView.snp.updateConstraints { (make) in
                make.width.equalTo(15)
                make.height.equalTo(12)
            }
        case .logout:
            iconImageView.snp.updateConstraints { (make) in
                make.width.height.equalTo(15)
            }
        }
    }
    
}
