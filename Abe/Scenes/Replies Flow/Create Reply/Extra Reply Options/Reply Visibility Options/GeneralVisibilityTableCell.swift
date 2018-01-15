
import Foundation
import UIKit

final class GeneralVisibilityTableCell: UITableViewCell, ValueCell {
    
    // MARK: - Properties
    typealias Value = Visibility
    static var defaultReusableId: String = "GeneralVisibilityTableCell"
    fileprivate var containerView: UIView!
    fileprivate var mainLabel: UILabel!
    
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
        setupContainerView()
        setupTitleLabel()
    }
    
    // MARK: - Configuration
    func configureWith(value: Visibility) {
        switch value {
        case .all:
            mainLabel.text = "Everyone"
        case .contacts:
            mainLabel.text = "Contacts only"
        default:
            break
        }
    }
    
    private func configureUserDidNotReplyState() {
        mainLabel.text = "You must make your reply FIRST"
    }
    
}

extension GeneralVisibilityTableCell {
    
    //MARK: View Setup
    private func setupContainerView() {
        containerView = UIView()
        containerView.backgroundColor = UIColor.white
        
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.edges.equalTo(contentView)
            make.height.equalTo(50)
        }
    }
    
    private func setupTitleLabel() {
        mainLabel = UILabel()
        
        containerView.addSubview(mainLabel)
        mainLabel.translatesAutoresizingMaskIntoConstraints = false
        mainLabel.snp.makeConstraints { (make) in
            //make.bottom.equalTo(collectionView.snp.top).offset(-5)
            make.center.equalTo(containerView.snp.center)
            //make.left.equalTo(containerView.snp.left).offset(10)
        }
    }
    
}
