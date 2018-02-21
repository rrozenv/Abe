
import Foundation
import UIKit

final class ProfileHeaderView: UIView {
    
    var containerView: UIView!
    var userImageView: UIImageView!
    var nameLabel: UILabel!
    var nameSubLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: .zero)
        setupContainerView()
        setupStackView()
    }
    
    func populateInfoWith(currentUser: User) {
        nameLabel.text = currentUser.name
        nameSubLabel.text = String(currentUser.coins)
    }
    
    private func setupContainerView() {
        containerView = UIView()
        
        self.addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
    
    private func setupStackView() {
        userImageView = UIImageView()
        userImageView.layer.cornerRadius = 36/2
        userImageView.layer.masksToBounds = true
        userImageView.backgroundColor = Palette.faintGrey.color
        userImageView.snp.makeConstraints { (make) in make.height.width.equalTo(36) }
        
        nameLabel = UILabel()
        nameLabel.textColor = UIColor.black
        nameLabel.numberOfLines = 1
        nameLabel.font = FontBook.AvenirHeavy.of(size: 13)
        
        nameSubLabel = UILabel()
        nameSubLabel.textColor = UIColor.gray
        nameSubLabel.numberOfLines = 1
        nameSubLabel.font = FontBook.AvenirMedium.of(size: 12)
        
        let views: [UIView] = [userImageView, nameLabel, nameSubLabel]
        let labelsStackView = UIStackView(arrangedSubviews: views)
        labelsStackView.spacing = 10.0
        labelsStackView.axis = .vertical
        labelsStackView.alignment = .center
        
        containerView.addSubview(labelsStackView)
        labelsStackView.snp.makeConstraints { (make) in
            make.top.equalTo(containerView).offset(10)
            make.bottom.equalTo(containerView).offset(-10)
            make.centerX.equalTo(containerView)
        }
    }
    
}
