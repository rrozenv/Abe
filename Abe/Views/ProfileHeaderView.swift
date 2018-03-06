
import Foundation
import UIKit

final class ProfileHeaderView: UIView {
    
    var containerView: UIView!
    var userImageView: UIImageView!
    var imageButton: UIButton!
    var nameLabel: UILabel!
    var nameSubLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: .zero)
        setupContainerView()
        setupStackView()
        setupImageButton()
    }
    
    func populateInfoWith(currentUser: User) {
        if let imageData = currentUser.avatarImageData {
            userImageView.image = UIImage(data: imageData)
        }
        nameLabel.text = currentUser.name
        nameSubLabel.text = String(currentUser.coins)
    }
    
    private func setupContainerView() {
        containerView = UIView()
        containerView.backgroundColor = UIColor.white
        
        self.addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
    
    private func setupStackView() {
        userImageView = UIImageView()
        userImageView.layer.cornerRadius = 72/2
        userImageView.layer.masksToBounds = true
        userImageView.backgroundColor = Palette.faintGrey.color
        userImageView.snp.makeConstraints { (make) in make.height.width.equalTo(72) }
        
        nameLabel = UILabel()
        nameLabel.textColor = UIColor.black
        nameLabel.numberOfLines = 1
        nameLabel.font = FontBook.BariolBold.of(size: 19)
        
        nameSubLabel = UILabel()
        nameSubLabel.textColor = Palette.red.color
        nameSubLabel.numberOfLines = 1
        nameSubLabel.font = FontBook.BariolBold.of(size: 16)
        
        let views: [UIView] = [userImageView, nameLabel, nameSubLabel]
        let labelsStackView = UIStackView(arrangedSubviews: views)
        labelsStackView.spacing = 14.0
        labelsStackView.axis = .vertical
        labelsStackView.alignment = .center
        
        containerView.addSubview(labelsStackView)
        labelsStackView.snp.makeConstraints { (make) in
            make.top.equalTo(containerView).offset(16)
            make.bottom.equalTo(containerView).offset(-16)
            make.centerX.equalTo(containerView)
        }
    }
    
    private func setupImageButton() {
        imageButton = UIButton()
        imageButton.backgroundColor = UIColor.clear
        
        containerView.addSubview(imageButton)
        imageButton.snp.makeConstraints { (make) in
            make.edges.equalTo(userImageView)
        }
    }
    
}
