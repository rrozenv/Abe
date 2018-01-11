
import Foundation
import UIKit
import RealmSwift

internal final class RepliesDataSource: ValueCellDataSource {
    
    internal enum Section: Int {
        case summary
        case replies
    }
    
    func load(replies: [PromptReply], userDidReply: Bool) {
        self.clearValues(section: Section.replies.rawValue)
        
        if replies.isEmpty {
            self.set(values: replies,
                     cellClass: ReplyTableCell.self,
                     inSection: Section.replies.rawValue)
        }
        
        self.set(values: replies,
                 cellClass: ReplyTableCell.self,
                 inSection: Section.replies.rawValue)
    }
    
    func loadBeforeUserRepliedState() {
        self.clearValues(section: Section.replies.rawValue)
        let emptyStateViewModel = RepliesEmptyStateViewModel(filterOption: .locked,
                                                             userDidReply: false)
        self.set(values: [emptyStateViewModel],
                 cellClass: RepliesEmptyCell.self,
                 inSection: Section.replies.rawValue)
    }
    
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
    
    func load(myReply: PromptReply, scores: [ReplyScore]) {
        self.set(values: scores,
                 cellClass: SavedReplyScoreTableCell.self,
                 inSection: Section.replies.rawValue)
        self.prependRow(value: myReply,
                        cellClass: ReplyTableCell.self,
                        toSection: Section.replies.rawValue)
    }
    
    func realmLoad(replies: Results<PromptReply>) {
        let section = Section.replies.rawValue
        self.clearValues(section: section)
        self.realmSet(values: replies,
                      cellClass: ReplyTableCell.self,
                      inSection: section)
    }
    
    func updateReply(_ reply: PromptReply, at indexPath: IndexPath) {
        self.set(value: reply,
                 cellClass: ReplyTableCell.self,
                 inSection: indexPath.section,
                 row: indexPath.row)
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
        case let (cell as SavedReplyScoreTableCell, value as ReplyScore):
            cell.configureWith(value: value)
        case let (cell as RepliesEmptyCell, value as RepliesEmptyStateViewModel):
            cell.configureWith(value: value)
        default:
            assertionFailure("Unrecognized combo: \(cell), \(value)")
        }
    }
    
}

internal final class ReplyScoresDataSource: ValueCellDataSource {
    
    internal enum Section: Int {
        case defaultSection
    }
    
    func load(scores: [ScoreCellViewModel]) {
        let section = Section.defaultSection.rawValue
        //self.clearValues(section: section)
        self.set(values: scores,
                 cellClass: ScoreCollectionCell.self,
                 inSection: section)
    }
    
    internal func scoreAtIndexPath(_ indexPath: IndexPath) -> ScoreCellViewModel? {
        return self[indexPath] as? ScoreCellViewModel
    }
    
    override func configureCell(collectionCell cell: UICollectionViewCell,
                                withValue value: Any) {
        switch (cell, value) {
        case let (cell as ScoreCollectionCell, value as ScoreCellViewModel):
            cell.configureWith(value: value)
        default:
            assertionFailure("Unrecognized combo: \(cell), \(value)")
        }
    }
    
}


