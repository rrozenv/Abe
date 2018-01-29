
import Foundation
import UIKit
import Kingfisher

final class UserImageNameSublabelView: UIView {
    
    var userImageView: UIImageView!
    var nameLabel: UILabel!
    var nameSubLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: .zero)
        setupUserImageView()
        setupNameLabelsStackView()
    }
    
    func populateInfoWith(name: String, subLabel: String) {
        nameLabel.text = name
        nameSubLabel.text = subLabel
//        if let url = URL(string: imageUrl) {
//            userImageView.kf.setImage(with: url)
//        }
    }
    
    private func setupUserImageView() {
        userImageView = UIImageView()
        userImageView.layer.cornerRadius = 36/2
        userImageView.layer.masksToBounds = true
        userImageView.backgroundColor = Palette.faintGrey.color
        
        self.addSubview(userImageView)
        userImageView.snp.makeConstraints { (make) in
            make.left.bottom.top.equalTo(self)
            make.height.width.equalTo(36)
        }
    }
    
    private func setupNameLabelsStackView() {
        nameLabel = UILabel()
        nameLabel.textColor = UIColor.black
        nameLabel.numberOfLines = 1
        nameLabel.font = FontBook.AvenirHeavy.of(size: 13)
        
        nameSubLabel = UILabel()
        nameSubLabel.textColor = UIColor.gray
        nameSubLabel.numberOfLines = 1
        nameSubLabel.font = FontBook.AvenirMedium.of(size: 12)
        
        let views: [UILabel] = [nameLabel, nameSubLabel]
        let labelsStackView = UIStackView(arrangedSubviews: views)
        labelsStackView.spacing = 2.0
        labelsStackView.axis = .vertical
        
        self.addSubview(labelsStackView)
        labelsStackView.snp.makeConstraints { (make) in
            make.centerY.equalTo(userImageView.snp.centerY)
            make.left.equalTo(userImageView.snp.right).offset(10)
        }
    }
    
}

