
import Foundation
import UIKit

final class RepliesEmptyView: UIView {
    
    var containerView: UIView!
    var titleLabel: UILabel!
    var selectedVisibility: Visibility = .all {
        didSet {
            self.setTitleText(for: selectedVisibility)
        }
    }
    
    //MARK: Initalizer Setup
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: .zero)
        setupContainerView()
        setupTitleLabel()
    }
    
    private func setupContainerView() {
        containerView = UIView()
        containerView.backgroundColor = UIColor.red
        
        self.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.snp.makeConstraints { (make) in
            make.edges.edges.equalTo(self)
        }
    }
    
    private func setupTitleLabel() {
        titleLabel = UILabel()
        
        containerView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.snp.makeConstraints { (make) in
            make.center.equalTo(containerView.snp.center)
        }
    }
    
    private func setTitleText(for visibility: Visibility) {
        switch visibility {
        case .all: titleLabel.text = "No Trending Replies"
        case .contacts: titleLabel.text = "No Replies For Contacts"
        case .userReply: titleLabel.text = "You did not reply"
        default: break
        }
    }
    
}
