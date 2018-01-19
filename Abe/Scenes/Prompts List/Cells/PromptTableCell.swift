
import Foundation
import UIKit
import Kingfisher
import SnapKit

final class PromptTableCell: UITableViewCell {
    
    // MARK: - Type Properties
    static let reuseIdentifier = "PromptTableCell"
    
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
    
    func configure(with prompt: Prompt) {
        promptView.headerView.titleLabel.text = prompt.title
        promptView.replyTextLabel.text = "replies"
        promptView.replyCountLabel.text = "\(prompt.replies.count)"
        if let url = URL(string: prompt.imageURL) {
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

