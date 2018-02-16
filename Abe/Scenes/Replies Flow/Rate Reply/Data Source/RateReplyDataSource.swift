
import Foundation
import UIKit

final class RatingScoreDataSource: ValueCellDataSource {
    
    enum Section: Int {
        case reply
        case ratings
    }
    
    func loadUnlockedReply(viewModel: ReplyViewModel) {
        self.set(values: [viewModel],
                 cellClass: RateReplyTableCell.self,
                 inSection: Section.reply.rawValue)
    }
    
    func loadRatings(ratings: [RatingScoreViewModel]) {
        self.set(values: ratings,
                 cellClass: RatingScoreTableCell.self,
                 inSection: Section.ratings.rawValue)
    }
    
    func toggleRating(at indexPath: IndexPath) {
        guard var viewModel = self.rating(indexPath) else { return }
        viewModel.isSelected = !viewModel.isSelected
        self.set(value: viewModel,
                 cellClass: RatingScoreTableCell.self,
                 inSection: Section.ratings.rawValue,
                 row: indexPath.row)
    }
    
    func rating(_ indexPath: IndexPath) -> RatingScoreViewModel? {
        return self[indexPath] as? RatingScoreViewModel
    }
    
    //MARK: - Configure Cell
    override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
        switch (cell, value) {
        case let (cell as RatingScoreTableCell, value as RatingScoreViewModel):
            cell.configureWith(value: value)
        case let (cell as RateReplyTableCell, value as ReplyViewModel):
            cell.configureWith(value: value)
            cell.hideRateButton()
        default:
            assertionFailure("Unrecognized combo: \(cell), \(value)")
        }
    }
    
}
