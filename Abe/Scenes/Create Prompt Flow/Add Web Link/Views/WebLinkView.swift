
import Foundation
import UIKit

final class WebThumbnailView: UIView {
    
    var containerView: UIView!
    var imageView: UIImageView!
    var titleLabel: UILabel!
    var urlLabel: UILabel!
    var labelsStackView: UIStackView!
    
    var thumbnail: WebLinkThumbnail? {
        didSet {
            guard let thumbnail = thumbnail else { return }
            self.titleLabel.text = thumbnail.title
            self.urlLabel.text = thumbnail.canonicalUrl == "" ? thumbnail.canonicalUrl : thumbnail.url
            if let url = URL(string: thumbnail.mainImageUrl) {
                self.imageView.kf.setImage(with: url)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //Important for dynamic height layout
        titleLabel.preferredMaxLayoutWidth = titleLabel.bounds.width
        urlLabel.preferredMaxLayoutWidth = urlLabel.bounds.width
    }
    
    init() {
        super.init(frame: .zero)
        self.backgroundColor = Palette.faintGrey.color
        self.layer.cornerRadius = 5.0
        self.layer.masksToBounds = true
        setupImageView()
        setupLabelsStackView()
    }
    
    private func setupImageView() {
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        
        self.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.left.top.bottom.equalTo(self)
            make.width.height.equalTo(76)
        }
    }
    
    private func setupLabelsStackView() {
        titleLabel = UILabel()
        titleLabel.textColor = UIColor.black
        titleLabel.numberOfLines = 2
        titleLabel.font = FontBook.AvenirHeavy.of(size: 13)
        
        urlLabel = UILabel()
        urlLabel.textColor = UIColor.gray
        urlLabel.numberOfLines = 1
        urlLabel.font = FontBook.AvenirMedium.of(size: 11)
        
        let views: [UILabel] = [titleLabel, urlLabel]
        labelsStackView = UIStackView(arrangedSubviews: views)
        labelsStackView.spacing = 4.0
        labelsStackView.axis = .vertical
        
        self.addSubview(labelsStackView)
        labelsStackView.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.snp.centerY)
            make.left.equalTo(imageView.snp.right).offset(10)
            make.right.equalTo(self.snp.right).offset(-10)
        }
    }
    
}
