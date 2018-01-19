
import Foundation
import UIKit

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
        setupImageView()
        setupOpaqueView()
        setupTitleLabel()
    }
    
    private func setupImageView() {
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        
        self.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
    
    private func setupOpaqueView() {
        opaqueView = UIView()
        opaqueView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        
        self.addSubview(opaqueView)
        opaqueView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
    
    private func setupTitleLabel() {
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

extension PromptHeaderView {
    
    func decrementOpaqueViewAlpha(offset: CGFloat) {
        if self.opaqueView.alpha <= 1 {
            let alphaOffset = (offset/500)/85
            self.opaqueView.alpha += alphaOffset
        }
    }
    
    func decrementTitleLabelAlpha(offset: CGFloat) {
        if self.titleLabel.alpha >= 0 {
            let alphaOffset = max((offset - 65)/85.0, 0)
            self.titleLabel.alpha = alphaOffset
        }
    }
    
    func incrementOpaqueViewAlpha(offset: CGFloat) {
        if self.opaqueView.alpha >= 0.6 {
            let alphaOffset = (offset/200)/85
            self.opaqueView.alpha -= alphaOffset
        }
    }
    
    func incrementTitleLabelAlpha(offset: CGFloat) {
        if self.titleLabel.alpha <= 1 {
            let alphaOffset = max((offset - 65)/85, 0)
            self.titleLabel.alpha = alphaOffset
        }
    }
    
}
