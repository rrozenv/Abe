
import Foundation
import UIKit

struct RepliesEmptyStateViewModel {
    let filterOption: FilterOption
    let userDidReply: Bool
}

final class RepliesEmptyCell: UITableViewCell, ValueCell {
    
    // MARK: - Properties
    typealias Value = RepliesEmptyStateViewModel
    static var defaultReusableId: String = "RepliesEmptyCell"
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
    func configureWith(value: RepliesEmptyStateViewModel) {
        guard value.userDidReply else { configureUserDidNotReplyState() ; return }
        switch value.filterOption {
        case .locked:
            mainLabel.text = "You have no LOCKED unread replies."
        case .unlocked:
            mainLabel.text = "You have no UNLOCKED replies."
        case .myReply:
            mainLabel.text = "No one has voted on your reply yet."
        }
    }
    
    private func configureUserDidNotReplyState() {
        mainLabel.text = "You must make your reply FIRST"
    }
    
}

extension RepliesEmptyCell {
    
    //MARK: View Setup
    private func setupContainerView() {
        containerView = UIView()
        containerView.backgroundColor = UIColor.white
        
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.edges.equalTo(contentView)
            make.height.equalTo(200)
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


