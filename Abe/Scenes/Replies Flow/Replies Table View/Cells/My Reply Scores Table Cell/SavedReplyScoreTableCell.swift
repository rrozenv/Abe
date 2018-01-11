
import Foundation
import UIKit

final class SavedReplyScoreTableCell: UITableViewCell, ValueCell {

    // MARK: - Properties
    typealias Value = ReplyScore
    static var defaultReusableId: String = "SavedReplyScoreTableCell"
    fileprivate var containerView: UIView!
    fileprivate var scoreLabel: UILabel!
    
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
        setupTitleLabel()
    }
    
    // MARK: - Configure Value
    func configureWith(value: ReplyScore) {
        scoreLabel.text = "\(value.score)"
    }
    
}

extension SavedReplyScoreTableCell {
    
    // MARK: - View Setup
    private func setupContainerView() {
        containerView = UIView()
        containerView.backgroundColor = UIColor.white
        
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.edges.equalTo(contentView)
            make.height.equalTo(80)
        }
    }
    
    private func setupTitleLabel() {
        scoreLabel = UILabel()
        
        containerView.addSubview(scoreLabel)
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.snp.makeConstraints { (make) in
            make.center.equalTo(containerView.snp.center)
        }
    }
    
}
