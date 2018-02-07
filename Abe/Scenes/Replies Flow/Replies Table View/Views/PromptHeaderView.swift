
import Foundation
import UIKit

final class GuessedUserView: UIView {
    
    var userImageView: UIImageView!
    var nameLabel: UILabel!
    var nameSubLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: .zero)
        setupUserImageView()
        setupNameLabelsStackView()
    }
    
    private func setupUserImageView() {
        userImageView = UIImageView()
        userImageView.backgroundColor = UIColor.purple
        
        self.addSubview(userImageView)
        userImageView.snp.makeConstraints { (make) in
            make.left.equalTo(self.snp.left).offset(20)
            make.centerY.equalTo(self.snp.centerY)
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
        
        self.addSubview(labelsStackView)
        labelsStackView.snp.makeConstraints { (make) in
            make.centerY.equalTo(userImageView.snp.centerY)
            make.left.equalTo(userImageView.snp.right).offset(10)
        }
    }
    
}

final class ReplyHeaderView: UIView {
    
    var userImageView: UIImageView!
    var nameLabel: UILabel!
    var nameSubLabel: UILabel!
    var replyBodyLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: .zero)
        setupReplyLabel()
        setupUserImageView()
        setupNameLabelsStackView()
    }
    
    func populateInfoWith(reply: PromptReply) {
        nameLabel.text = reply.user?.name
        nameSubLabel.text = "From Contacts"
        replyBodyLabel.text = reply.body
    }
    
    private func setupReplyLabel() {
        replyBodyLabel = UILabel()
        replyBodyLabel.numberOfLines = 0
        replyBodyLabel.font = FontBook.AvenirMedium.of(size: 14)
        
        self.addSubview(replyBodyLabel)
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
        
        self.addSubview(userImageView)
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
        
        self.addSubview(labelsStackView)
        labelsStackView.snp.makeConstraints { (make) in
            make.centerY.equalTo(userImageView.snp.centerY)
            make.left.equalTo(userImageView.snp.right).offset(10)
        }
    }

}

final class PromptHeaderView: UIView {
    
    var topContainerView: UIView!
    var titleLabel: UILabel!
    var imageView: UIImageView!
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
        imageView = UIImageView()
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
