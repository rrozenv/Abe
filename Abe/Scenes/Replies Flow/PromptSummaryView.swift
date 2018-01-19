
import Foundation
import UIKit

final class PromptSummaryView: UIView {
    
    var containerView: UIView!
    var bodyTextLabel: UILabel!
    var contentStackView: UIStackView!
    var webLinkView: WebThumbnailView!
    var testWebLinkView: UIView!

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
        setupBodyTextProperties()
        setupWebLinkViewProperties()
        setupContentStackView()
    }

    private func setupBodyTextProperties() {
        bodyTextLabel = UILabel()
        bodyTextLabel.textColor = UIColor.black
        bodyTextLabel.numberOfLines = 0
        bodyTextLabel.font = FontBook.AvenirMedium.of(size: 18)
    }
    
    private func setupWebLinkViewProperties() {
        webLinkView = WebThumbnailView()
    }
    
    private func setupContentStackView() {
        let views: [UIView] = [bodyTextLabel, webLinkView]
        contentStackView = UIStackView(arrangedSubviews: views)
        contentStackView.spacing = 4.0
        contentStackView.axis = .vertical
        
        self.addSubview(contentStackView)
        contentStackView.snp.makeConstraints { (make) in
            make.edges.equalTo(self).inset(20)
        }
    }
    
}
