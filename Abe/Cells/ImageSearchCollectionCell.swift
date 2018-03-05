
import Foundation
import UIKit
import Gifu

//class GIFImageView: UIImageView, GIFAnimatable {
//    public lazy var animator: Animator? = {
//        return Animator(withDelegate: self)
//    }()
//    
//    override public func display(_ layer: CALayer) {
//        updateImageIfNeeded()
//    }
//}

//extension UIImageView: GIFAnimatable {
//    private struct AssociatedKeys {
//        static var AnimatorKey = "gifu.animator.key"
//    }
//
//    override open func display(_ layer: CALayer) {
//        updateImageIfNeeded()
//    }
//
//    public var animator: Animator? {
//        get {
//            guard let animator = objc_getAssociatedObject(self, &AssociatedKeys.AnimatorKey) as? Animator else {
//                let animator = Animator(withDelegate: self)
//                self.animator = animator
//                return animator
//            }
//
//            return animator
//        }
//
//        set {
//            objc_setAssociatedObject(self, &AssociatedKeys.AnimatorKey, newValue as Animator?, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//        }
//    }
//}

class ImageSearchCollectionCell: UICollectionViewCell, ValueCell {

    static var defaultReusableId: String = "ScoreCollectionCell"
    typealias Value = ImageRepresentable
    var imageView: GIFImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupImageView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureWith(value: ImageRepresentable) {
       guard let url = URL(string: value.webformatURL) else { return }
        imageView.kf.indicatorType = .activity
        UIView.animate(withDuration: 0.2, animations: { self.imageView.kf.setImage(with: url) })
        
//        guard let url = URL(string: value.webformatURL) else { return }
//        imageView.animate(withGIFURL: url)
//        imageView.prepareForAnimation(withGIFURL: url)
//        imageView.startAnimating()
    }
    
    func prepareForAnimation(value: ImageRepresentable) {
        guard let url = URL(string: value.webformatURL) else { return }
        imageView.prepareForAnimation(withGIFURL: url)
    }
    
    func endAnimation() {
        imageView.stopAnimating()
    }
    
    fileprivate func setupImageView() {
        imageView = GIFImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.edges.equalTo(contentView)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.prepareForReuse()
    }
    
}
