
import Foundation
import UIKit

final class PromptView: UIView {
    
    var containerView: UIView!
    var bottomContainerView: UIView!
    var replyCountLabel: UILabel!
    var replyTextLabel: UILabel!
    var replyLabelsStackView: UIStackView!
    var headerView: PromptHeaderView!
    var userImageNameReplyView: UserImageNameSublabelView!

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: .zero)
        self.backgroundColor = UIColor.clear
        setupContainerView()
        setupBottomContainerView()
        setupImageNameReplyView()
        setupHeaderView()
    }
    
    private func setupContainerView() {
        containerView = UIView()
        containerView.dropShadow()
        
        self.addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
    
    private func setupBottomContainerView() {
        bottomContainerView = UIView()
        bottomContainerView.backgroundColor = UIColor.white
        
        containerView.addSubview(bottomContainerView)
        bottomContainerView.snp.makeConstraints { (make) in
            make.right.left.bottom.equalTo(containerView)
            make.height.equalTo(88)
        }
    }
    
    private func setupImageNameReplyView() {
        userImageNameReplyView = UserImageNameSublabelView()
        
        bottomContainerView.addSubview(userImageNameReplyView)
        userImageNameReplyView.snp.makeConstraints { (make) in
            make.centerY.equalTo(bottomContainerView)
            make.left.equalTo(bottomContainerView).offset(20)
            make.right.equalTo(bottomContainerView).offset(-40)
        }
    }
    
    private func setupHeaderView() {
        headerView = PromptHeaderView()
        
        containerView.addSubview(headerView)
        headerView.snp.makeConstraints { (make) in
            make.right.left.top.equalTo(containerView)
            make.bottom.equalTo(bottomContainerView.snp.top)
            make.height.equalTo(186)
        }
    }

    func reset() {
        headerView.imageView.image = nil
        headerView.titleLabel.text = nil
        userImageNameReplyView.nameLabel.text = nil
        userImageNameReplyView.nameSubLabel.text = nil
        userImageNameReplyView.userImageView.image = nil
    }
    
}




