
import Foundation
import UIKit
import Kingfisher
import SnapKit

final class PromptTableCell: UITableViewCell, ValueCell {

    // MARK: - Type Properties
    typealias Value = Prompt
    static var defaultReusableId: String = "PromptTableCell"
    
    // MARK: - Properties
    fileprivate var promptView: PromptView!
    
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
        setupPromptView()
    }
    
    func configureWith(value: Prompt) {
        promptView.headerView.titleLabel.text = value.title
        promptView.replyTextLabel.text = "replies"
        promptView.replyCountLabel.text = "\(value.replies.count)"
        if let url = URL(string: value.imageURL) {
            print(url)
            promptView.headerView.imageView.kf.setImage(with: url)
        }
    }
    
    override func prepareForReuse() {
        promptView.reset()
    }
    
}

//MARK: Constraints Setup

extension PromptTableCell {
    
    func setupPromptView() {
        promptView = PromptView()
        
        contentView.addSubview(promptView)
        promptView.snp.makeConstraints { (make) in
            make.edges.equalTo(contentView).inset(UIEdgeInsetsMake(20, 20, 10, 20))
        }
    }
    
}

