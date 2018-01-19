
import Foundation
import UIKit
import GSKStretchyHeaderView

final class PromptView: UIView {
    
    private let height1X: CGFloat = 154.0
    var containerView: UIView!
    var bottomContainerView: UIView!
    var replyCountLabel: UILabel!
    var replyTextLabel: UILabel!
    var replyLabelsStackView: UIStackView!
    
//    var topContainerView: UIView!
//    var titleLabel: UILabel!
//    var imageView: UIImageView!
//    var opaqueView: UIView!
    var headerView: PromptHeaderView!
//
//    var height: CGFloat {
//        return Screen.height * (height1X / Screen.height)
//    }
    
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
//        setupTopContainerView()
//        setupImageView()
//        setupOpaqueView()
//        setupTitleLabel()
    }
    
    fileprivate func setupContainerView() {
        containerView = UIView()
        containerView.dropShadow()
        
        self.addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
    
    fileprivate func setupBottomContainerView() {
        bottomContainerView = UIView()
        bottomContainerView.backgroundColor = UIColor.blue
        
        containerView.addSubview(bottomContainerView)
        bottomContainerView.snp.makeConstraints { (make) in
            make.right.left.bottom.equalTo(containerView)
            make.height.equalTo(88)
        }
    }
    
    fileprivate func setupReplyCountLabelProperties() {
        replyCountLabel = UILabel()
        replyCountLabel.textColor = UIColor.black
        replyCountLabel.numberOfLines = 1
        replyCountLabel.font = FontBook.AvenirHeavy.of(size: 13)
    }
    
    fileprivate func setupReplyTextLabelProperties() {
        replyTextLabel = UILabel()
        replyTextLabel.textColor = UIColor.black
        replyTextLabel.numberOfLines = 0
        replyTextLabel.font = FontBook.AvenirMedium.of(size: 12)
    }
    
    fileprivate func setupReplyLabelsStackView() {
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
    
//    fileprivate func setupTopContainerView() {
//        topContainerView = UIView()
//
//        containerView.addSubview(topContainerView)
//        topContainerView.snp.makeConstraints { (make) in
//            make.right.left.top.equalTo(containerView)
//            make.bottom.equalTo(bottomContainerView.snp.top)
//            make.height.equalTo(186)
//        }
//    }
//
//    fileprivate func setupImageView() {
//        imageView = UIImageView()
//
//        topContainerView.addSubview(imageView)
//        imageView.snp.makeConstraints { (make) in
//            make.edges.equalTo(topContainerView)
//        }
//    }
//
//    fileprivate func setupOpaqueView() {
//        opaqueView = UIView()
//        opaqueView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
//
//        topContainerView.addSubview(opaqueView)
//        opaqueView.snp.makeConstraints { (make) in
//            make.edges.equalTo(imageView)
//        }
//    }
//
//    fileprivate func setupTitleLabel() {
//        titleLabel = UILabel()
//        titleLabel.textColor = UIColor.white
//        titleLabel.numberOfLines = 0
//        titleLabel.font = FontBook.AvenirBlack.of(size: 19)
//
//        topContainerView.addSubview(titleLabel)
//        titleLabel.snp.makeConstraints { (make) in
//            make.left.equalTo(topContainerView).offset(20)
//            make.bottom.equalTo(topContainerView).offset(-20)
//            make.right.equalTo(topContainerView).offset(-20)
//        }
//    }
    
    func reset() {
        headerView.imageView.image = nil
        headerView.titleLabel.text = nil
        replyTextLabel.text = nil
        replyCountLabel.text = nil
    }
    
}

final class PromptHeaderSummaryView: UIView {
    
    var headerView: PromptHeaderView!
    var summaryView: PromptSummaryView!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: .zero)
        self.backgroundColor = UIColor.red
        setupHeaderView()
        setupSummaryView()
    }
    
    private func setupHeaderView() {
        headerView = PromptHeaderView()
        
        self.addSubview(headerView)
        headerView.snp.makeConstraints { (make) in
            make.left.right.top.equalTo(self)
            make.height.equalTo(150)
        }
    }
    
    private func setupSummaryView() {
        summaryView = PromptSummaryView()
        
        self.addSubview(summaryView)
        summaryView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(self)
            make.top.equalTo(headerView)
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
        //setupTopContainerView()
        setupImageView()
        setupOpaqueView()
        setupTitleLabel()
    }
    
    fileprivate func setupImageView() {
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        
        self.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
    
    fileprivate func setupOpaqueView() {
        opaqueView = UIView()
        opaqueView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        
        self.addSubview(opaqueView)
        opaqueView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
    
    fileprivate func setupTitleLabel() {
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

final class PromptHeaderPlusSummaryView: UIView {
    
    var topContainerView: UIView!
    var titleLabel: UILabel!
    var imageView: UIImageView!
    var opaqueView: UIView!
    var bodyTextLabel: UILabel!
    var contentStackView: UIStackView!
    var webLinkView: WebThumbnailView!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: .zero)
        self.backgroundColor = UIColor.red
        //setupTopContainerView()
        setupImageView()
        setupOpaqueView()
        setupTitleLabel()
        setupBodyTextProperties()
        setupWebLinkViewProperties()
        setupContentStackView()
    }
    
    fileprivate func setupImageView() {
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        
        self.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.left.right.top.equalTo(self)
            make.height.equalTo(150)
        }
    }
    
    fileprivate func setupOpaqueView() {
        opaqueView = UIView()
        opaqueView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        
        self.addSubview(opaqueView)
        opaqueView.snp.makeConstraints { (make) in
            make.edges.equalTo(imageView)
        }
    }
    
    fileprivate func setupTitleLabel() {
        titleLabel = UILabel()
        titleLabel.textColor = UIColor.white
        titleLabel.numberOfLines = 0
        titleLabel.font = FontBook.AvenirBlack.of(size: 19)
        
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(imageView).offset(20)
            make.bottom.equalTo(imageView).offset(-20)
            make.right.equalTo(imageView).offset(-20)
        }
    }
    
    fileprivate func setupBodyTextProperties() {
        bodyTextLabel = UILabel()
        bodyTextLabel.textColor = UIColor.black
        bodyTextLabel.numberOfLines = 0
        bodyTextLabel.font = FontBook.AvenirMedium.of(size: 12)
    }
    
    fileprivate func setupWebLinkViewProperties() {
        webLinkView = WebThumbnailView()
    }
    
    fileprivate func setupContentStackView() {
        let views: [UIView] = [bodyTextLabel, webLinkView]
        contentStackView = UIStackView(arrangedSubviews: views)
        contentStackView.spacing = 4.0
        contentStackView.axis = .vertical
        
        self.addSubview(contentStackView)
        contentStackView.snp.makeConstraints { (make) in
            make.left.right.equalTo(self).inset(20)
            make.top.equalTo(imageView.snp.bottom).offset(-10)
            make.bottom.equalTo(self.snp.bottom)
        }
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
