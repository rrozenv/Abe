
import Foundation
import UIKit

final class GuessAndReplyValidationDataSource: ValueCellDataSource {
    
    func loadScores(_ scores: [ReplyScore]) {
        self.set(values: scores,
                 cellClass: SavedReplyScoreTableCell.self,
                 inSection: 0)
    }
    
    func rating(_ indexPath: IndexPath) -> ReplyScore? {
        return self[indexPath] as? ReplyScore
    }
    
    //MARK: - Configure Cell
    override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
        switch (cell, value) {
        case let (cell as SavedReplyScoreTableCell, value as ReplyScore):
            cell.configureWith(value: value)
        default:
            assertionFailure("Unrecognized combo: \(cell), \(value)")
        }
    }
    
}
