
import Foundation
import UIKit

final class UserContactTableCell: UITableViewCell, ValueCell {
    
    // MARK: - Properties
    typealias Value = IndividualContactViewModel
    static var defaultReusableId: String = "UserContactTableCell"
    fileprivate var containerView: UIView!
    fileprivate var mainLabel: UILabel!
    
    var isSelect: Bool = false {
        didSet {
            self.containerView.backgroundColor = isSelect ? UIColor.green : UIColor.white
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
    }
    
    // MARK: - Configuration
    func configureWith(value: IndividualContactViewModel) {
        mainLabel.text = value.user.name
        isSelect = value.isSelected
    }
    
}

extension UserContactTableCell {
    
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
