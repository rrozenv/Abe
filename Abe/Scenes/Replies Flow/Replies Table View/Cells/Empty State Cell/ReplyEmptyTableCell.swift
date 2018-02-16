
import Foundation
import UIKit

struct RepliesEmptyStateViewModel {
    let filterOption: FilterOption
    let userDidReply: Bool
    let replyCount: Int?
}

final class RepliesEmptyCell: UITableViewCell, ValueCell {
    
    // MARK: - Properties
    typealias Value = RepliesEmptyStateViewModel
    static var defaultReusableId: String = "RepliesEmptyCell"
    private var containerView: UIView!
    private var headerLabel: UILabel!
    private var bodyLabel: UILabel!
    private var iconImageView: UIImageView!
    private var stackView: UIStackView!
    
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
        setupIconImageView()
        setupHeaderLabel()
        setupBodyLabel()
        setupStackView()
    }
    
    // MARK: - Configuration
    func configureWith(value: RepliesEmptyStateViewModel) {
        guard value.userDidReply else { configureUserDidNotReplyState(replyCount: value.replyCount ?? 0) ; return }
        iconImageView.isHidden = true
        switch value.filterOption {
        case .locked:
            headerLabel.text = "No Locked Replies."
            bodyLabel.text = "You have unlocked all replies for this topic. Congrats champ!"
        case .unlocked:
            headerLabel.text = "No Unlocked Replies."
            bodyLabel.text = "Go unlock some replies you silly goose!"
        case .myReply:
            headerLabel.text = "No Ratings."
            bodyLabel.text = "No one has rated your reply yet. Tell your friends to get on it!"
        }
    }
    
    private func configureUserDidNotReplyState(replyCount: Int) {
        headerLabel.text = (replyCount != 0) ? "\(replyCount) Replies Locked" : "Replies Locked."
        bodyLabel.text = "Replies will unlock after you submit yours. You will only have one chance to reply so make it count!"
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.isHidden = false
    }
    
}

extension RepliesEmptyCell {
    
    //MARK: View Setup
    private func setupContainerView() {
        containerView = UIView()
        containerView.backgroundColor = UIColor.white
        
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.top.equalTo(contentView).offset(50)
            make.bottom.equalTo(contentView)
            make.centerX.equalTo(contentView)
            make.width.equalTo(contentView).multipliedBy(0.7)
        }
    }
    
    private func setupIconImageView() {
        iconImageView = UIImageView(image: #imageLiteral(resourceName: "IC_LockedReplies"))
        iconImageView.contentMode = .scaleAspectFit
    }
    
    private func setupHeaderLabel() {
        headerLabel = UILabel()
        headerLabel.font = FontBook.AvenirHeavy.of(size: 15)
        headerLabel.textColor = UIColor.black
        headerLabel.textAlignment = .center
    }
    
    private func setupBodyLabel() {
        bodyLabel = UILabel()
        bodyLabel.font = FontBook.AvenirMedium.of(size: 14)
        bodyLabel.textColor = Palette.lightGrey.color
        bodyLabel.numberOfLines = 0
        bodyLabel.textAlignment = .center
    }
    
    private func setupStackView() {
        let fields: [UIView] = [iconImageView, headerLabel, bodyLabel]
        let stackView = UIStackView(arrangedSubviews: fields)
        stackView.axis = .vertical
        stackView.spacing = 14
        
        containerView.addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.edges.equalTo(containerView)
        }
    }
    
}


