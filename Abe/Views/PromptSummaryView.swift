
import Foundation
import UIKit

final class PromptSummaryView: UIView {
    
    var containerView: UIView!
    var topView: UIView!
    var topLabel: UILabel!
    var bodyTextLabel: UILabel!
    var contentStackView: UIStackView!
    var webLinkView: WebThumbnailView!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: .zero)
        self.backgroundColor = UIColor.clear
        setupContainerView()
        setupBodyTextProperties()
        setupWebLinkViewProperties()
        setupTopView()
        setupContentStackView()
    }
    
    fileprivate func setupContainerView() {
        containerView = UIView()
        containerView.backgroundColor = UIColor.white
        
        self.addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
    
    fileprivate func setupBodyTextProperties() {
        bodyTextLabel = UILabel()
        bodyTextLabel.textColor = UIColor.black
        bodyTextLabel.numberOfLines = 0
        bodyTextLabel.font = FontBook.AvenirMedium.of(size: 14)
    }
    
    fileprivate func setupWebLinkViewProperties() {
        webLinkView = WebThumbnailView()
        webLinkView.placeholderBackgroundView.isHidden = true
    }
    
    private func setupTopView() {
        topView = UIView()
        topView.backgroundColor = Palette.brightYellow.color
        
        containerView.addSubview(topView)
        topView.snp.makeConstraints { (make) in
            make.height.equalTo(40)
            make.left.right.top.equalTo(containerView)
        }
        
        topLabel = UILabel()
        topLabel.font = FontBook.AvenirHeavy.of(size: 14)
        topLabel.textColor = Palette.darkYellow.color
        topLabel.text = "dfdasfdasfdsafasdfasdf"
        
        topView.addSubview(topLabel)
        topLabel.snp.makeConstraints { (make) in
            make.center.equalTo(topView)
        }
    }
    
    fileprivate func setupContentStackView() {
        let views: [UIView] = [bodyTextLabel, webLinkView]
        contentStackView = UIStackView(arrangedSubviews: views)
        contentStackView.spacing = 14.0
        contentStackView.axis = .vertical
        
        containerView.addSubview(contentStackView)
        contentStackView.snp.makeConstraints { (make) in
            make.top.equalTo(topView.snp.bottom).offset(18)
            make.bottom.equalTo(containerView).offset(-18)
            make.left.equalTo(containerView).offset(26)
            make.right.equalTo(containerView).offset(-26)
        }
    }
    
}
