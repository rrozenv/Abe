
import Foundation
import UIKit
import SnapKit

final class CustomNavigationBar: UIView {
    
    var containerView: UIView!
    var leftButton: UIButton!
    var centerButton: UIButton!
    var rightButton: UIButton!

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(leftImage: UIImage,
         centerImage: UIImage,
         rightImage: UIImage) {
        super.init(frame: .zero)
        self.backgroundColor = UIColor.clear
        setupBackgroundView()
        setupLeftButton(with: leftImage)
        setupCenterButton(with: centerImage)
        setupRightButton(with: rightImage)
    }
    
}

extension CustomNavigationBar {
    
    private func setupBackgroundView() {
        containerView = UIView()
        containerView.backgroundColor = UIColor.white
        containerView.layer.masksToBounds = true
        
        self.addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
    
    private func setupLeftButton(with image: UIImage) {
        leftButton = UIButton()
        leftButton.backgroundColor = UIColor.clear
        leftButton.setImage(image, for: .normal)
        
        containerView.addSubview(leftButton)
        leftButton.snp.makeConstraints { (make) in
            make.width.height.equalTo(containerView.snp.width).multipliedBy(0.072)
            make.left.equalTo(containerView.snp.left).offset(24)
            make.centerY.equalTo(containerView.snp.centerY)
        }
    }
    
    private func setupCenterButton(with image: UIImage) {
        centerButton = UIButton()
        centerButton.backgroundColor = UIColor.clear
        centerButton.setImage(image, for: .normal)
        
        containerView.addSubview(centerButton)
        centerButton.snp.makeConstraints { (make) in
            make.width.height.equalTo(containerView.snp.width).multipliedBy(0.205)
            make.centerX.equalTo(containerView.snp.centerX)
            make.bottom.equalTo(containerView.snp.bottom).offset(12)
        }
    }
    
    private func setupRightButton(with image: UIImage) {
        rightButton = UIButton()
        rightButton.backgroundColor = UIColor.clear
        rightButton.setImage(image, for: .normal)
        
        containerView.addSubview(rightButton)
        rightButton.snp.makeConstraints { (make) in
            make.width.equalTo(containerView.snp.width).multipliedBy(0.060)
            make.height.equalTo(containerView.snp.width).multipliedBy(0.068)
            make.right.equalTo(containerView.snp.right).offset(-24)
            make.centerY.equalTo(containerView.snp.centerY)
        }
    }
    
}

