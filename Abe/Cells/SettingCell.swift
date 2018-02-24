
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
        setupTitleLabel()
        setupIconImageView()
    }
    
    // MARK: - Configuration
    func configureWith(value: Setting) {
        mainLabel.text = value.type.rawValue
        iconImageView.image = value.iconImage
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
            make.center.equalTo(containerView.snp.center)
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
