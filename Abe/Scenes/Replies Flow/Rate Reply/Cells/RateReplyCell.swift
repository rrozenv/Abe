
import Foundation
import UIKit

final class RatingScoreTableCell: UITableViewCell, ValueCell {
    
    // MARK: - Properties
    typealias Value = RatingScore
    static var defaultReusableId: String = "RatingScoreTableCell"
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
    func configureWith(value: RatingScore) {
        mainLabel.text = "Rating: \(value.value)"
        isSelect = value.isSelected
    }
    
}

extension RatingScoreTableCell {
    
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
