
import Foundation
import UIKit

final class RepliesEmptyView: UIView {
    
    var containerView: UIView!
    var titleLabel: UILabel!
    var selectedVisibility: Visibility = .all {
        didSet {
            self.setTitleText(for: selectedVisibility)
        }
    }
    
    //MARK: Initalizer Setup
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: .zero)
        setupContainerView()
        setupTitleLabel()
    }
    
    private func setupContainerView() {
        containerView = UIView()
        containerView.backgroundColor = UIColor.red
        
        self.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.snp.makeConstraints { (make) in
            make.edges.edges.equalTo(self)
        }
    }
    
    private func setupTitleLabel() {
        titleLabel = UILabel()
        
        containerView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.snp.makeConstraints { (make) in
            make.center.equalTo(containerView.snp.center)
        }
    }
    
    private func setTitleText(for visibility: Visibility) {
        switch visibility {
        case .all: titleLabel.text = "No Trending Replies"
        case .contacts: titleLabel.text = "No Replies For Contacts"
        case .userReply: titleLabel.text = "You did not reply"
        default: break
        }
    }
    
}

final class ContactsTableHeaderView: UIView {
    
    var containerView: UIView!
    var actionButton: UIButton!
    var titleLabel: UILabel!
    
    //MARK: Initalizer Setup
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: .zero)
        self.backgroundColor = UIColor.orange
        setupContainerView()
        setupTitleLabel()
        setupActionButton()
    }
    
    private func setupContainerView() {
        containerView = UIView()
        
        self.addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
            make.height.equalTo(60)
        }
    }
    
    private func setupActionButton() {
        actionButton = UIButton()
        actionButton.backgroundColor = UIColor.red
        
        containerView.addSubview(actionButton)
        actionButton.snp.makeConstraints { (make) in
            make.top.right.bottom.equalTo(containerView)
            make.width.equalTo(100)
        }
    }
    
    private func setupTitleLabel() {
        titleLabel = UILabel()
        
        containerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(containerView).offset(26)
            make.centerY.equalTo(containerView.snp.centerY)
        }
    }
    
}
