
import Foundation
import UIKit
import Kingfisher
import SnapKit

final class PromptTableCell: UITableViewCell, ValueCell {

    // MARK: - Type Properties
    typealias Value = Prompt
    static var defaultReusableId: String = "PromptTableCell"
    
    // MARK: - Properties
    private var containerView: UIView!
    private var promptView: PromptView!
    
    // MARK: - Initialization
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func commonInit() {
        self.contentView.backgroundColor = UIColor.white
        self.separatorInset = .zero
        self.preservesSuperviewLayoutMargins = false
        self.layoutMargins = .zero
        self.selectionStyle = .none
        setupContainerView()
        setupPromptView()
    }
    
    func configureWith(value: Prompt) {
        guard let user = AppController.shared.currentUser.value else { fatalError() }
        promptView.headerView.titleLabel.text = value.title
        promptView.userImageNameReplyView.nameLabel.text = value.user?.name
        promptView.userImageNameReplyView.nameSubLabel.text = "\(value.replies.count) replies"
//        promptView.replyTextLabel.text = "replies"
//        promptView.replyCountLabel.text = "\(value.replies.count)"
        if let url = URL(string: value.imageURL) {
            print(url)
            promptView.headerView.imageView.kf.setImage(with: url)
        }
        
        let friendReplyCount = value.replies
            .filter(NSPredicate(format: "ANY user.registeredContacts.phoneNumber = %@", user.phoneNumber)).count
        print("Friend reply count: \(friendReplyCount)")
    }
    
    override func prepareForReuse() {
        promptView.reset()
    }
    
}

//MARK: Constraints Setup

extension PromptTableCell {
    
    private func setupContainerView() {
        containerView = UIView()
        containerView.layer.cornerRadius = 10.0
        containerView.layer.masksToBounds = true
        containerView.dropShadow()
        
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.edges.equalTo(contentView).inset(UIEdgeInsetsMake(10, 20, 10, 20))
        }
    }
    
    private func setupPromptView() {
        promptView = PromptView()
        
        containerView.addSubview(promptView)
        promptView.snp.makeConstraints { (make) in
            make.edges.equalTo(containerView)
        }
    }
    
}

