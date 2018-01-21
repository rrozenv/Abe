
import Foundation
import UIKit

final class RatingScoreDataSource: ValueCellDataSource {
    
    func loadRatings(ratings: [RatingScore]) {
        self.set(values: ratings,
                 cellClass: RatingScoreTableCell.self,
                 inSection: 0)
    }
    
    func toggleRating(at indexPath: IndexPath) {
        guard var viewModel = self.rating(indexPath) else { return }
        viewModel.isSelected = !viewModel.isSelected
        self.set(value: viewModel,
                 cellClass: RatingScoreTableCell.self,
                 inSection: 0,
                 row: indexPath.row)
    }
    
    func rating(_ indexPath: IndexPath) -> RatingScore? {
        return self[indexPath] as? RatingScore
    }
    
    //MARK: - Configure Cell
    override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
        switch (cell, value) {
        case let (cell as RatingScoreTableCell, value as RatingScore):
            cell.configureWith(value: value)
        default:
            assertionFailure("Unrecognized combo: \(cell), \(value)")
        }
    }
    
}
