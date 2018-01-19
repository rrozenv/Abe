
import Foundation
import UIKit

final class PromptSummaryView: UIView {
    
    var containerView: UIView!
    var bodyTextLabel: UILabel!
    var contentStackView: UIStackView!
    //var webLinkView: WebThumbnailView!

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        bodyTextLabel.preferredMaxLayoutWidth = bodyTextLabel.bounds.width
    }
    
    init() {
        super.init(frame: .zero)
        self.backgroundColor = UIColor.clear
        //setupContainerView()
        setupBodyTextProperties()
        //setupWebLinkViewProperties()
        //setupContentStackView()
    }
    
//    fileprivate func setupContainerView() {
//        containerView = UIView()
//        containerView.backgroundColor = UIColor.yellow
//
//        self.addSubview(containerView)
//        containerView.snp.makeConstraints { (make) in
//            make.edges.equalTo(self)
//        }
//    }

    fileprivate func setupBodyTextProperties() {
        bodyTextLabel = UILabel()
        bodyTextLabel.textColor = UIColor.black
        bodyTextLabel.numberOfLines = 0
        bodyTextLabel.font = FontBook.AvenirMedium.of(size: 18)
        
        self.addSubview(bodyTextLabel)
        bodyTextLabel.snp.makeConstraints { (make) in
            make.edges.equalTo(self).inset(20)
        }
    }
    
//    fileprivate func setupWebLinkViewProperties() {
//        webLinkView = WebThumbnailView()
//        webLinkView.frame.size.height = 100
//    }
    
    fileprivate func setupContentStackView() {
        let views: [UIView] = [bodyTextLabel]
        contentStackView = UIStackView(arrangedSubviews: views)
        contentStackView.spacing = 4.0
        contentStackView.axis = .vertical
        
        self.addSubview(contentStackView)
        contentStackView.snp.makeConstraints { (make) in
            make.edges.equalTo(self).inset(20)
        }
    }
    
}
