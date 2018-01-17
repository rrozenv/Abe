
import Foundation
import UIKit

class ImageSearchCollectionViewLayout: UICollectionViewFlowLayout {
    
    let itemSpacing: CGFloat = 2
    let itemsPerRow: CGFloat = 3
    
    init(topInset: CGFloat?) {
        super.init()
        self.minimumLineSpacing = itemSpacing
        self.minimumInteritemSpacing = itemSpacing / 2
        self.scrollDirection = .vertical
        self.sectionInset = UIEdgeInsetsMake(topInset ?? 0, 0, 0, 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
    }
    
    func itemWidth() -> CGFloat {
        return (collectionView!.frame.size.width/self.itemsPerRow) - (self.itemSpacing / 2)
    }
    
    override var itemSize: CGSize {
        set {
            self.itemSize = CGSize(width:itemWidth(), height: itemWidth())
        }
        get {
            return CGSize(width:itemWidth(), height: itemWidth())
        }
    }
    
}
