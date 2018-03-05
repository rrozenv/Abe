
import Foundation
import UIKit

struct ImageSearchEmptyStateViewModel {
    let mainText: String
}

final class ImageSearchDataSource: ValueCellDataSource {
    
    private var displayedImages = [ImageRepresentable]()
    
    //MARK: - Locked Replies Tab
    func load(images: [ImageRepresentable]) {
        //let emptyStateViewModel = ImageSearchEmptyStateViewModel(mainText: "No Images")
//        if replies.isEmpty {
//            self.set(values: [emptyStateViewModel],
//                     cellClass: ImageSearchCollectionCell.self,
//                     inSection: 0)
//        } else {
            self.displayedImages = images
            self.set(values: images,
                     cellClass: ImageSearchCollectionCell.self,
                     inSection: 0)
//        }
    }
    
    func loadPaginated(images: [ImageRepresentable]) {
        let allImages = displayedImages + images
        self.displayedImages = allImages
        self.set(values: allImages,
                 cellClass: ImageSearchCollectionCell.self,
                 inSection: 0)
    }
    
    func shouldLoadMoreResults(_ indexPath: IndexPath) -> Bool {
        return indexPath.item == self.displayedImages.count - 1
    }
    
    //MARK: - Read Current Value Methods
    func imageAtIndexPath(_ indexPath: IndexPath) -> ImageRepresentable? {
        return self[indexPath] as? ImageRepresentable
    }
    
    //MARK: - Configure Cell
    override func configureCell(collectionCell cell: UICollectionViewCell, withValue value: Any) {
        switch (cell, value) {
        case let (cell as ImageSearchCollectionCell, value as ImageRepresentable):
            cell.configureWith(value: value)
        default:
            assertionFailure("Unrecognized combo: \(cell), \(value)")
        }
    }
    
}
