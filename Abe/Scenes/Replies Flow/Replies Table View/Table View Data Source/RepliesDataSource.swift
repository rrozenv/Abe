
import Foundation
import UIKit
import RealmSwift

final class RepliesDataSource: ValueCellDataSource {
    
    enum Section: Int {
        case summary
        case replies
    }
    
    //MARK: - Before User Replied
    func loadBeforeUserRepliedState() {
        self.clearValues(section: Section.replies.rawValue)
        let emptyStateViewModel = RepliesEmptyStateViewModel(filterOption: .locked,
                                                             userDidReply: false)
        self.set(values: [emptyStateViewModel],
                 cellClass: RepliesEmptyCell.self,
                 inSection: Section.replies.rawValue)
    }
    
    //MARK: - Locked Replies Tab
    func loadLocked(replies: [PromptReply], didReply: Bool) {
        self.clearValues(section: Section.replies.rawValue)
        let emptyStateViewModel = RepliesEmptyStateViewModel(filterOption: .locked,
                                                            userDidReply: didReply)
        if replies.isEmpty {
            self.set(values: [emptyStateViewModel],
                     cellClass: RepliesEmptyCell.self,
                     inSection: Section.replies.rawValue)
        } else {
            self.set(values: replies,
                     cellClass: ReplyTableCell.self,
                     inSection: Section.replies.rawValue)
        }
    }
    
    //MARK: - Unlocked Replies Tab
    func loadUnlocked(replies: [PromptReply]) {
        self.clearValues(section: Section.replies.rawValue)
        let emptyStateViewModel = RepliesEmptyStateViewModel(filterOption: .locked,
                                                             userDidReply: true)
        if replies.isEmpty {
            self.set(values: [emptyStateViewModel],
                     cellClass: RepliesEmptyCell.self,
                     inSection: Section.replies.rawValue)
        } else {
            self.set(values: replies,
                     cellClass: ReplyTableCell.self,
                     inSection: Section.replies.rawValue)
        }
    }
    
    //MARK: - My Reply Tab
    func load(myReply: PromptReply, scores: [ReplyScore]) {
        self.set(values: scores,
                 cellClass: SavedReplyScoreTableCell.self,
                 inSection: Section.replies.rawValue)
        self.prependRow(value: myReply,
                        cellClass: ReplyTableCell.self,
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
        case let (cell as ReplyTableCell, value as PromptReply):
            cell.configureWith(value: value)
        case let (cell as SavedReplyScoreTableCell, value as ReplyScore):
            cell.configureWith(value: value)
        case let (cell as RepliesEmptyCell, value as RepliesEmptyStateViewModel):
            cell.configureWith(value: value)
        default:
            assertionFailure("Unrecognized combo: \(cell), \(value)")
        }
    }
    
}

//func realmLoad(replies: Results<PromptReply>) {
//    let section = Section.replies.rawValue
//    self.clearValues(section: section)
//    self.realmSet(values: replies,
//                  cellClass: ReplyTableCell.self,
//                  inSection: section)
//}




