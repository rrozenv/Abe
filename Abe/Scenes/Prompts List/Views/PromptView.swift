
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
//        setupReplyCountLabelProperties()
//        setupReplyTextLabelProperties()
//        setupReplyLabelsStackView()
        
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
    
    private func setupReplyCountLabelProperties() {
        replyCountLabel = UILabel()
        replyCountLabel.textColor = UIColor.black
        replyCountLabel.numberOfLines = 1
        replyCountLabel.font = FontBook.AvenirHeavy.of(size: 13)
    }
    
    private func setupReplyTextLabelProperties() {
        replyTextLabel = UILabel()
        replyTextLabel.textColor = UIColor.black
        replyTextLabel.numberOfLines = 0
        replyTextLabel.font = FontBook.AvenirMedium.of(size: 12)
    }
    
    private func setupReplyLabelsStackView() {
        let views: [UILabel] = [replyCountLabel, replyTextLabel]
        replyLabelsStackView = UIStackView(arrangedSubviews: views)
        replyLabelsStackView.spacing = 4.0
        replyLabelsStackView.axis = .vertical
        
        bottomContainerView.addSubview(replyLabelsStackView)
        replyLabelsStackView.snp.makeConstraints { (make) in
            make.centerY.equalTo(bottomContainerView)
            make.leading.equalTo(bottomContainerView).offset(20)
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
//        replyTextLabel.text = nil
//        replyCountLabel.text = nil
    }
    
}




