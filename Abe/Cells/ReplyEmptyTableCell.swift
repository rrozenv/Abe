
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
    private var titleLabelWithIconImageView: LeftIconImageViewWithLabel!
    private var bodyLabel: UILabel!
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
        setupTitleLabelWithIconImageView()
        setupBodyLabel()
        setupStackView()
    }
    
    // MARK: - Configuration
    func configureWith(value: RepliesEmptyStateViewModel) {
        guard value.userDidReply else { configureUserDidNotReplyState(replyCount: value.replyCount ?? 0) ; return }
        titleLabelWithIconImageView.imageView.isHidden = true
        switch value.filterOption {
        case .locked:
            titleLabelWithIconImageView.label.text = "No Locked Replies."
            bodyLabel.text = "You have unlocked all replies for this topic. Congrats champ!"
        case .unlocked:
            titleLabelWithIconImageView.label.text = "No Unlocked Replies."
            bodyLabel.text = "Go unlock some replies you silly goose!"
        case .myReply:
            titleLabelWithIconImageView.label.text = "No Ratings."
            bodyLabel.text = "No one has rated your reply yet. Tell your friends to get on it!"
        }
    }
    
    private func configureUserDidNotReplyState(replyCount: Int) {
        titleLabelWithIconImageView.label.text = (replyCount != 0) ? "\(replyCount) Replies Locked" : "Replies Locked."
        bodyLabel.text = "Replies will unlock after you submit yours. You will only have one chance to reply so make it count!"
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabelWithIconImageView.imageView.isHidden = false
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
    
    private func setupTitleLabelWithIconImageView() {
        titleLabelWithIconImageView = LeftIconImageViewWithLabel()
        titleLabelWithIconImageView.label.font = FontBook.BariolBold.of(size: 17)
        titleLabelWithIconImageView.label.textColor = UIColor.black
        //titleLabelWithIconImageView.label.textAlignment = .center
        
        titleLabelWithIconImageView.imageView.image = #imageLiteral(resourceName: "IC_YellowLock")
        titleLabelWithIconImageView.imageView.contentMode = .scaleAspectFit
    }
    
    private func setupBodyLabel() {
        bodyLabel = UILabel()
        bodyLabel.font = FontBook.AvenirMedium.of(size: 14)
        bodyLabel.textColor = Palette.lightGrey.color
        bodyLabel.numberOfLines = 0
        bodyLabel.textAlignment = .center
    }
    
    private func setupStackView() {
        let iconLabel: [UIView] = [titleLabelWithIconImageView, bodyLabel]
        let iconLabelStackView = UIStackView(arrangedSubviews: iconLabel)
        iconLabelStackView.axis = .vertical
        iconLabelStackView.spacing = 8
        iconLabelStackView.distribution = .equalCentering
        iconLabelStackView.alignment = .center
        
        containerView.addSubview(iconLabelStackView)
        iconLabelStackView.snp.makeConstraints { (make) in
            make.edges.equalTo(containerView)
        }
    }
    
}


