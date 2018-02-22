
import Foundation
import UIKit

final class SavedReplyScoreView: UIView {
    
    var containerView: UIView!
    var userImageView: UIImageView!
    var nameLabel: UILabel!
    var nameSubLabel: UILabel!
    var replyBodyLabel: UILabel!
    var iconImageView: UIImageView!
    var replyBodyStackView: UIStackView!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: .zero)
        setupContainerView()
        setupUserImageView()
        setupReplyLabel()
        setupNameLabelsStackView()
        setupIconImageView()
    }
    
    private func setupContainerView() {
        containerView = UIView()
        
        self.addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
    
    func populateInfoWith(score: ReplyScore, currentUser: User) {
        nameLabel.text = score.user?.name
        nameSubLabel.text = ""
//        nameSubLabel.text = score.isAuthorInCurrentUserContacts(currentUser: currentUser) ? "From Contacts" : ""
        replyBodyLabel.text = score.comment
        replyBodyLabel.isHidden = score.comment != "" ? false : true
        iconImageView.image = imageForRating(value: score.score)
    }
    
    private func setupReplyLabel() {
        replyBodyLabel = UILabel()
        replyBodyLabel.numberOfLines = 0
        replyBodyLabel.font = FontBook.AvenirMedium.of(size: 14)
        
        let whiteDividerView = UIView()
        whiteDividerView.snp.makeConstraints { (make) in make.height.equalTo(1) }
        
        let views: [UIView] = [whiteDividerView, replyBodyLabel]
        replyBodyStackView = UIStackView(arrangedSubviews: views)
        replyBodyStackView.axis = .vertical
        
        containerView.addSubview(replyBodyStackView)
        replyBodyStackView.snp.makeConstraints { (make) in
            make.top.equalTo(userImageView.snp.bottom).offset(10)
            make.left.equalTo(self.snp.left).offset(20)
            make.right.equalTo(self.snp.right).offset(-20)
            make.bottom.equalTo(self.snp.bottom).offset(-12)
        }
        
//        containerView.addSubview(replyBodyLabel)
//        replyBodyLabel.snp.makeConstraints { (make) in
//            make.left.equalTo(self.snp.left).offset(20)
//            make.right.equalTo(self.snp.right).offset(-20)
//            make.bottom.equalTo(self.snp.bottom).offset(-20)
//        }
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
            //make.bottom.equalTo(replyBodyLabel.snp.top).offset(-17)
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
    
    private func setupIconImageView() {
        iconImageView = UIImageView()
        iconImageView.layer.cornerRadius = 11/2
        iconImageView.layer.masksToBounds = true
        iconImageView.backgroundColor = Palette.faintGrey.color
        
        containerView.addSubview(iconImageView)
        iconImageView.snp.makeConstraints { (make) in
            make.right.equalTo(self.snp.right).offset(-20)
            make.top.equalTo(self.snp.top).offset(17)
            make.height.width.equalTo(22)
        }
    }
    
}

final class SavedReplyScoreTableCell: UITableViewCell, ValueCell {

    // MARK: - Properties
    typealias Value = ReplyScore
    static var defaultReusableId: String = "SavedReplyScoreTableCell"
    fileprivate var containerView: UIView!
    fileprivate var scoreLabel: UILabel!
    private var scoreView: SavedReplyScoreView!
    
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
        setupScoreView()
    }
    
    // MARK: - Configure Value
    func configureWith(value: ReplyScore) {
        guard let user = AppController.shared.currentUser.value else { fatalError() }
        scoreView.populateInfoWith(score: value, currentUser: user)
    }
    
}

extension SavedReplyScoreTableCell {
    
    // MARK: - View Setup
    private func setupContainerView() {
        containerView = UIView()
        containerView.backgroundColor = UIColor.white
        containerView.layer.cornerRadius = 5.0
        containerView.dropShadow()
        
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.edges.equalTo(contentView).inset(UIEdgeInsetsMake(8, 26, 8, 26))
//            make.left.equalTo(contentView).offset(26)
//            make.right.equalTo(contentView).offset(-26)
//            make.top.equalTo(contentView).offset(16)
//            make.bottom.equalTo(contentView)
        }
    }
    
    private func setupScoreView() {
        scoreView = SavedReplyScoreView()
        
        containerView.addSubview(scoreView)
        scoreView.snp.makeConstraints { (make) in
            make.edges.equalTo(containerView)
        }
    }
    
}
