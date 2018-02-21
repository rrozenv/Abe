
import Foundation
import UIKit
import Kingfisher

final class WebThumbnailView: UIView {
    
    var containerView: UIView!
    var imageView: UIImageView!
    var titleLabel: UILabel!
    var urlLabel: UILabel!
    var labelsStackView: UIStackView!
    
    var placeholderBackgroundView: UIView!
    var placeholderImageView: UIImageView!
    var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    var thumbnail: WebLinkThumbnail? {
        didSet {
            guard let thumbnail = thumbnail else { clearData(); return }
            self.titleLabel.text = thumbnail.title
            self.urlLabel.text = thumbnail.canonicalUrl == "" ? thumbnail.canonicalUrl : thumbnail.url
            if let url = URL(string: thumbnail.mainImageUrl) {
                imageView.kf.indicatorType = .activity
                self.imageView.kf.setImage(with: url)
            }
        }
    }
    
    private func clearData() {
        imageView.image = nil
        titleLabel.text = nil
        urlLabel.text = nil
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
        self.layer.cornerRadius = 2.0
        self.layer.masksToBounds = true
        setupImageView()
        setupLabelsStackView()
        setupPlaceholderBackgroundView()
        setupPlaceholderImageView()
        setupLoadingIndicator()
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
    
    private func setupPlaceholderBackgroundView() {
        placeholderBackgroundView = UIView()
        placeholderBackgroundView.backgroundColor = UIColor.white
        
        self.addSubview(placeholderBackgroundView)
        placeholderBackgroundView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
    
    private func setupPlaceholderImageView() {
        placeholderImageView = UIImageView(image: #imageLiteral(resourceName: "IC_WebIcon"))
        placeholderImageView.contentMode = .scaleAspectFit
        
        placeholderBackgroundView.addSubview(placeholderImageView)
        placeholderImageView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalTo(self).multipliedBy(0.1923)
            make.height.equalTo(self).multipliedBy(0.64)
        }
    }
    
    private func setupLoadingIndicator() {
        activityIndicator.hidesWhenStopped = true
        
        self.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { (make) in
            make.center.equalTo(self)
        }
    }
    
}
