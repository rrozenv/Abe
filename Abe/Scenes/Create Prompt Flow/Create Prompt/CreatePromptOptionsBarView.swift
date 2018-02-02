
import Foundation
import UIKit

final class CreatePromptOptionsBarView: UIView {
    
    var containerView: UIView!
    var addWebLinkButton: UIButton!
    var nextButton: UIButton!
    
    //MARK: Initalizer Setup
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: .zero)
        self.backgroundColor = UIColor.orange
        setupContainerView()
        setupAddLinkButton()
        setupNextButton()
    }
    
    private func setupContainerView() {
        containerView = UIView()
        containerView.backgroundColor = UIColor.white
        containerView.dropShadow()
        
        self.addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
    
    private func setupAddLinkButton() {
        addWebLinkButton = UIButton()
        addWebLinkButton.backgroundColor = UIColor.red
        
        containerView.addSubview(addWebLinkButton)
        addWebLinkButton.snp.makeConstraints { (make) in
            make.top.left.bottom.equalTo(containerView)
            make.width.equalTo(100)
        }
    }
    
    private func setupNextButton() {
        nextButton = UIButton()
        nextButton.backgroundColor = UIColor.red
        
        containerView.addSubview(nextButton)
        nextButton.snp.makeConstraints { (make) in
            make.top.right.bottom.equalTo(containerView)
            make.width.equalTo(100)
        }
    }
    
}
