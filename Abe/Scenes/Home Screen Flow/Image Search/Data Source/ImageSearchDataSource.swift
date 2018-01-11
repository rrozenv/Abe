
import Foundation
import UIKit

struct ImageSearchEmptyStateViewModel {
    let mainText: String
}

final class ImageSearchDataSource: ValueCellDataSource {
    
    //MARK: - Before User Replied
//    func loadBeforeUserRepliedState() {
//        self.clearValues(section: 0)
//        let emptyStateViewModel = ImageSearchEmptyStateViewModel(mainText: "Enter Search")
//        self.set(values: [emptyStateViewModel],
//                 cellClass: RepliesEmptyCell.self,
//                 inSection: 0)
//    }
    
    //MARK: - Locked Replies Tab
    func load(images: [PixaImage]) {
        //let emptyStateViewModel = ImageSearchEmptyStateViewModel(mainText: "No Images")
//        if replies.isEmpty {
//            self.set(values: [emptyStateViewModel],
//                     cellClass: ImageSearchCollectionCell.self,
//                     inSection: 0)
//        } else {
            self.set(values: images,
                     cellClass: ImageSearchCollectionCell.self,
                     inSection: 0)
//        }
    }
    
    //MARK: - Read Current Value Methods
    func imageAtIndexPath(_ indexPath: IndexPath) -> PixaImage? {
        return self[indexPath] as? PixaImage
    }
    
    //MARK: - Configure Cell
    override func configureCell(collectionCell cell: UICollectionViewCell, withValue value: Any) {
        switch (cell, value) {
        case let (cell as ImageSearchCollectionCell, value as PixaImage):
            cell.configureWith(value: value)
        default:
            assertionFailure("Unrecognized combo: \(cell), \(value)")
        }
    }
    
}
