
import Foundation
import UIKit
import RealmSwift

final class RepliesDataSource: ValueCellDataSource {
    
    enum Section: Int {
        case summary
        case replies
    }
    
    //MARK: - Before User Replied
    func loadBeforeUserRepliedState(replyCount: Int) {
        self.clearValues(section: Section.replies.rawValue)
        let emptyStateViewModel = RepliesEmptyStateViewModel(filterOption: .locked,
                                                             userDidReply: false,
                                                             replyCount: replyCount)
        self.set(values: [emptyStateViewModel],
                 cellClass: RepliesEmptyCell.self,
                 inSection: Section.summary.rawValue)
    }
    
    //MARK: - Locked Replies Tab
    func loadLocked(replies: [ReplyViewModel], didReply: Bool) {
        self.clearValues(section: Section.replies.rawValue)
        self.clearValues(section: Section.summary.rawValue)
        let emptyStateViewModel = RepliesEmptyStateViewModel(filterOption: .locked,
                                                             userDidReply: didReply,
                                                             replyCount: nil)
        if replies.isEmpty {
            self.set(values: [emptyStateViewModel],
                     cellClass: RepliesEmptyCell.self,
                     inSection: Section.replies.rawValue)
        } else {
            self.set(values: replies,
                     cellClass: RateReplyTableCell.self,
                     inSection: Section.replies.rawValue)
        }
    }
    
    //MARK: - Unlocked Replies Tab
    func loadUnlocked(replies: [ReplyViewModel]) {
        self.clearValues(section: Section.replies.rawValue)
        self.clearValues(section: Section.summary.rawValue)
        let emptyStateViewModel = RepliesEmptyStateViewModel(filterOption: .unlocked,
                                                             userDidReply: true,
                                                             replyCount: nil)
        if replies.isEmpty {
            self.set(values: [emptyStateViewModel],
                     cellClass: RepliesEmptyCell.self,
                     inSection: Section.replies.rawValue)
        } else {
            self.set(values: replies,
                     cellClass: RateReplyTableCell.self,
                     inSection: Section.replies.rawValue)
        }
    }
    
    //MARK: - My Reply Tab
    func load(replyVm: ReplyViewModel, graphVm: PercentageGraphViewModel) {
        self.clearValues(section: Section.replies.rawValue)
        self.set(values: replyVm.reply.scores.toArray(),
                 cellClass: SavedReplyScoreTableCell.self,
                 inSection: Section.replies.rawValue)
        self.prependRow(value: graphVm,
                        cellClass: RatingPercentageGraphCell.self,
                        toSection: Section.replies.rawValue)
        self.prependRow(value: replyVm,
                        cellClass: RateReplyTableCell.self,
                        toSection: Section.replies.rawValue)
    }
    
    //MARK: - Insert Updated Reply
    func updateReply(_ reply: PromptReply, at indexPath: IndexPath) {
        self.set(value: reply,
                 cellClass: ReplyTableCell.self,
                 inSection: indexPath.section,
                 row: indexPath.row)
    }
    
    //MARK: - Read Current Value Methods
    func replyAtIndexPath(_ indexPath: IndexPath) -> PromptReply? {
        return self[indexPath] as? PromptReply
    }
    
    func indexPath(forReplyRow row: Int) -> IndexPath {
        return IndexPath(item: row, section: Section.replies.rawValue)
    }
    
    //MARK: - Configure Cell
    override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
        switch (cell, value) {
//        case let (cell as ReplyTableCell, value as PromptReply):
//            cell.configureWith(value: value)
        case let (cell as RateReplyTableCell, value as ReplyViewModel):
            cell.configureWith(value: value)
        case let (cell as SavedReplyScoreTableCell, value as ReplyScore):
            cell.configureWith(value: value)
        case let (cell as RepliesEmptyCell, value as RepliesEmptyStateViewModel):
            cell.configureWith(value: value)
        case let (cell as RatingPercentageGraphCell, value as PercentageGraphViewModel):
            cell.configureWith(value: value)
        default:
            assertionFailure("Unrecognized combo: \(cell), \(value)")
        }
    }
    
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        <#code#>
//    }
    
}

//func realmLoad(replies: Results<PromptReply>) {
//    let section = Section.replies.rawValue
//    self.clearValues(section: section)
//    self.realmSet(values: replies,
//                  cellClass: ReplyTableCell.self,
//                  inSection: section)
//}




