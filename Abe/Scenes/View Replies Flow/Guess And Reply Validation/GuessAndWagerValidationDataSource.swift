
import Foundation
import UIKit

final class GuessAndReplyValidationDataSource: ValueCellDataSource {
    
    enum Section: Int {
        case reply
        case percentageGraph
        case ratingScores
    }
    
    func loadUnlockedReply(viewModel: ReplyViewModel) {
        self.set(values: [viewModel],
                 cellClass: RateReplyTableCell.self,
                 inSection: Section.reply.rawValue)
    }
    
    func loadPercentageGraph(viewModel: PercentageGraphViewModel) {
         self.set(values: [viewModel],
                  cellClass: RatingPercentageGraphCell.self,
                  inSection: Section.percentageGraph.rawValue)
    }
    
    func loadScores(_ scores: [ReplyScore]) {
        self.set(values: scores,
                 cellClass: SavedReplyScoreTableCell.self,
                 inSection: Section.ratingScores.rawValue)
    }
    
    func rating(_ indexPath: IndexPath) -> ReplyScore? {
        return self[indexPath] as? ReplyScore
    }
    
    //MARK: - Configure Cell
    override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
        switch (cell, value) {
        case let (cell as SavedReplyScoreTableCell, value as ReplyScore):
            cell.configureWith(value: value)
        case let (cell as RateReplyTableCell, value as ReplyViewModel):
            cell.configureWith(value: value)
            cell.hideRateButton()
        case let (cell as RatingPercentageGraphCell, value as PercentageGraphViewModel):
            cell.configureWith(value: value)
        default:
            assertionFailure("Unrecognized combo: \(cell), \(value)")
        }
    }
    
}
