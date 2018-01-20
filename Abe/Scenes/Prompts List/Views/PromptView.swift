
import Foundation
import UIKit
import GSKStretchyHeaderView

final class PromptView: UIView {
    
    var containerView: UIView!
    var bottomContainerView: UIView!
    var replyCountLabel: UILabel!
    var replyTextLabel: UILabel!
    var replyLabelsStackView: UIStackView!
    var headerView: PromptHeaderView!

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: .zero)
        self.backgroundColor = UIColor.clear
        setupContainerView()
        setupBottomContainerView()
        setupReplyCountLabelProperties()
        setupReplyTextLabelProperties()
        setupReplyLabelsStackView()
        
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
        bottomContainerView.backgroundColor = UIColor.blue
        
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
        replyTextLabel.text = nil
        replyCountLabel.text = nil
    }
    
}



extension UIView {
    
    func dropShadow(scale: Bool = true) {
        self.clipsToBounds = false
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: -1, height: 1)
        self.layer.shadowRadius = 5
    }
    
}

enum FontBook: String {
    case AvenirMedium = "Avenir-Medium"
    case AvenirHeavy = "Avenir-Heavy"
    case AvenirBlack = "Avenir-Black"
    
    func of(size: CGFloat) -> UIFont {
        return UIFont(name: self.rawValue, size: size)!
    }
}

extension String {
    
    var date: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let calendar = Calendar.current
        guard let date = formatter.date(from: self) else { return nil }
        let components = calendar.dateComponents([.month, .day, .hour, .minute], from: date)
        let finalDate = calendar.date(from:components)
        return finalDate
    }
    
}