
import Foundation
import UIKit

final class WebLinkActionButtonsView: UIView {
    
    var containerView: UIView!
    var searchButton: UIButton!
    var doneButton: UIButton!
    var displayDone: Bool = false {
        didSet {
            searchButton.isHidden = displayDone ? true : false
            doneButton.isHidden = displayDone ? false : true
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: .zero)
        self.backgroundColor = UIColor.clear
        setupContainerView()
        setupSearchButton()
        setupDoneButton()
    }
    
    private func setupContainerView() {
        containerView = UIView()
        containerView.backgroundColor = UIColor.white

        self.addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
    
    private func setupSearchButton() {
        searchButton = UIButton()
        searchButton.backgroundColor = UIColor.green
        searchButton.setTitle("Search", for: .normal)
        searchButton.isHidden = false
        
        containerView.addSubview(searchButton)
        searchButton.snp.makeConstraints { (make) in
            make.edges.equalTo(containerView)
        }
    }
    
    private func setupDoneButton() {
        doneButton = UIButton()
        doneButton.backgroundColor = UIColor.blue
        doneButton.setTitle("Done", for: .normal)
        doneButton.isHidden = true
        
        containerView.addSubview(doneButton)
        doneButton.snp.makeConstraints { (make) in
            make.edges.equalTo(containerView)
        }
    }
    
}

final class WebThumbnailView: UIView {
    
    var containerView: UIView!
    var imageView: UIImageView!
    //var imageViewContainer: UIView!
    var titleLabel: UILabel!
    var urlLabel: UILabel!
    var labelsStackView: UIStackView!
    var thumbnail: WebLinkThumbnail? {
        didSet {
            guard let thumbnail = thumbnail else { return }
            self.titleLabel.text = thumbnail.title
            self.urlLabel.text = thumbnail.canonicalUrl
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
        titleLabel.preferredMaxLayoutWidth = titleLabel.bounds.width
        urlLabel.preferredMaxLayoutWidth = urlLabel.bounds.width
    }
    
    init() {
        super.init(frame: .zero)
        self.backgroundColor = UIColor.gray
        //setupContainerView()
        setupImageView()
        setupLabelsStackView()
    }
    
//    private func setupContainerView() {
//        containerView = UIView()
//        containerView.backgroundColor = UIColor.lightGray
//        containerView.layer.cornerRadius = 5.0
//        containerView.layer.masksToBounds = true
//        containerView.dropShadow()
//
//        self.addSubview(containerView)
//        containerView.snp.makeConstraints { (make) in
//            make.edges.equalTo(self)
//            make.height.equalTo(100)
//        }
//    }
    
    private func setupImageView() {
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        
        self.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.left.top.bottom.equalTo(self)
            make.width.equalTo(100)
            make.height.equalTo(100)
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
//            make.top.equalTo(self.snp.top).offset(-10)
//            make.bottom.equalTo(self.snp.bottom).offset(10)
        }
    }
    
}
