
import Foundation
import UIKit

internal final class RepliesDataSource: ValueCellDataSource {
    
    internal enum Section: Int {
        case summary
        case replies
    }
    
    func load(replies: [PromptReply]) {
        let section = Section.replies.rawValue
        self.clearValues(section: section)
        self.set(values: replies,
                 cellClass: ReplyTableCell.self,
                 inSection: section)
    }
    
    internal func replyAtIndexPath(_ indexPath: IndexPath) -> PromptReply? {
        return self[indexPath] as? PromptReply
    }
    
    internal func indexPath(forReplyRow row: Int) -> IndexPath {
        return IndexPath(item: row, section: Section.replies.rawValue)
    }
    
    override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
        switch (cell, value) {
        case let (cell as ReplyTableCell, value as PromptReply):
            cell.configureWith(value: value)
        default:
            assertionFailure("Unrecognized combo: \(cell), \(value)")
        }
    }
    
}
