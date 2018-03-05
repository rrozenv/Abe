
import Foundation
import UIKit
import Kingfisher

final class GuessedUserView: UIView {
    
    var containerView: UIView!
    var userImageView: UIImageView!
    var nameLabel: UILabel!
    var nameSubLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(height: CGFloat) {
        super.init(frame: .zero)
        setupContainerView(height: height)
        setupUserImageView()
        setupNameLabelsStackView()
    }
    
    private func setupContainerView(height: CGFloat) {
        containerView = UIView()
        
        self.addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
            make.height.equalTo(height)
        }
    }
    
    private func setupUserImageView() {
        userImageView = UIImageView()
        userImageView.backgroundColor = UIColor.purple
        
        containerView.addSubview(userImageView)
        userImageView.snp.makeConstraints { (make) in
            make.left.equalTo(containerView.snp.left).offset(20)
            make.centerY.equalTo(containerView.snp.centerY)
            make.height.width.equalTo(35)
        }
    }
    
    private func setupNameLabelsStackView() {
        nameLabel = UILabel()
        nameLabel.textColor = UIColor.black
        nameLabel.numberOfLines = 1
        nameLabel.font = FontBook.AvenirHeavy.of(size: 13)
        
        nameSubLabel = UILabel()
        nameSubLabel.textColor = UIColor.gray
        nameSubLabel.numberOfLines = 1
        nameSubLabel.font = FontBook.AvenirMedium.of(size: 12)
        
        let views: [UILabel] = [nameLabel, nameSubLabel]
        let labelsStackView = UIStackView(arrangedSubviews: views)
        labelsStackView.spacing = 2.0
        labelsStackView.axis = .vertical
        
        containerView.addSubview(labelsStackView)
        labelsStackView.snp.makeConstraints { (make) in
            make.centerY.equalTo(userImageView.snp.centerY)
            make.left.equalTo(userImageView.snp.right).offset(10)
        }
    }
    
}

final class ReplyHeaderView: UIView {
    
    var containerView: UIView!
    var userImageView: UIImageView!
    var nameLabel: UILabel!
    var nameSubLabel: UILabel!
    var replyBodyLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: .zero)
        setupContainerView()
        setupReplyLabel()
        setupUserImageView()
        setupNameLabelsStackView()
    }
    
    private func setupContainerView() {
        containerView = UIView()
        
        self.addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
    
    func populateInfoWith(viewModel: ReplyViewModel) {
        nameLabel.text = viewModel.isUnlocked ? viewModel.reply.user?.name : "Identity Locked"
        nameSubLabel.text = viewModel.isCurrentUsersFriend ? "From Contacts" : ""
        replyBodyLabel.text = viewModel.reply.body
    }
    
    private func setupReplyLabel() {
        replyBodyLabel = UILabel()
        replyBodyLabel.numberOfLines = 0
        replyBodyLabel.font = FontBook.AvenirMedium.of(size: 14)
        
        containerView.addSubview(replyBodyLabel)
        replyBodyLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.snp.left).offset(20)
            make.right.equalTo(self.snp.right).offset(-20)
            make.bottom.equalTo(self.snp.bottom).offset(-20)
        }
    }
    
    private func setupUserImageView() {
        userImageView = UIImageView()
        userImageView.layer.cornerRadius = 36/2
        userImageView.layer.masksToBounds = true
        userImageView.backgroundColor = Palette.faintGrey.color
        
        containerView.addSubview(userImageView)
        userImageView.snp.makeConstraints { (make) in
            make.left.equalTo(self.snp.left).offset(20)
            make.top.equalTo(self.snp.top).offset(17)
            make.bottom.equalTo(replyBodyLabel.snp.top).offset(-17)
            make.height.width.equalTo(36)
        }
    }
    
    private func setupNameLabelsStackView() {
        nameLabel = UILabel()
        nameLabel.textColor = UIColor.black
        nameLabel.numberOfLines = 1
        nameLabel.font = FontBook.AvenirHeavy.of(size: 13)
        
        nameSubLabel = UILabel()
        nameSubLabel.textColor = UIColor.gray
        nameSubLabel.numberOfLines = 1
        nameSubLabel.font = FontBook.AvenirMedium.of(size: 12)
        
        let views: [UILabel] = [nameLabel, nameSubLabel]
        let labelsStackView = UIStackView(arrangedSubviews: views)
        labelsStackView.spacing = 2.0
        labelsStackView.axis = .vertical
        
        containerView.addSubview(labelsStackView)
        labelsStackView.snp.makeConstraints { (make) in
            make.centerY.equalTo(userImageView.snp.centerY)
            make.left.equalTo(userImageView.snp.right).offset(10)
        }
    }

}

final class PromptHeaderView: UIView {
    
    var topContainerView: UIView!
    var titleLabel: UILabel!
    var imageView: AnimatedImageView!
    var opaqueView: UIView!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: .zero)
        self.backgroundColor = UIColor.clear
        setupImageView()
        setupOpaqueView()
        setupTitleLabel()
    }
    
    private func setupImageView() {
        imageView = AnimatedImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        
        self.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
    
    private func setupOpaqueView() {
        opaqueView = UIView()
        opaqueView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        self.addSubview(opaqueView)
        opaqueView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
    
    private func setupTitleLabel() {
        titleLabel = UILabel()
        titleLabel.textColor = UIColor.white
        titleLabel.numberOfLines = 0
        titleLabel.font = FontBook.AvenirBlack.of(size: 19)
        
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(20)
            make.bottom.equalTo(self).offset(-20)
            make.right.equalTo(self).offset(-20)
        }
    }
    
}

extension PromptHeaderView {
    
    func decrementOpaqueViewAlpha(offset: CGFloat) {
        if self.opaqueView.alpha <= 1 {
            let alphaOffset = (offset/500)/85
            self.opaqueView.alpha += alphaOffset
        }
    }
    
    func decrementTitleLabelAlpha(offset: CGFloat) {
        if self.titleLabel.alpha >= 0 {
            let alphaOffset = max((offset - 65)/85.0, 0)
            self.titleLabel.alpha = alphaOffset
        }
    }
    
    func incrementOpaqueViewAlpha(offset: CGFloat) {
        if self.opaqueView.alpha >= 0.6 {
            let alphaOffset = (offset/200)/85
            self.opaqueView.alpha -= alphaOffset
        }
    }
    
    func incrementTitleLabelAlpha(offset: CGFloat) {
        if self.titleLabel.alpha <= 1 {
            let alphaOffset = max((offset - 65)/85, 0)
            self.titleLabel.alpha = alphaOffset
        }
    }
    
}
