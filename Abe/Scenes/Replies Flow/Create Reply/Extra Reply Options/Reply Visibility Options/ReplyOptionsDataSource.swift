
import Foundation
import UIKit

final class ReplyVisibilityDataSource: ValueCellDataSource {

    enum Section: Int {
        case generalVisibility
        case individualContacts
    }

    //MARK: - Locked Replies Tab
    func loadGeneralVisibility(options: [Visibility]) {
        self.clearValues(section: Section.generalVisibility.rawValue)
        self.set(values: options,
                 cellClass: GeneralVisibilityTableCell.self,
                 inSection: Section.generalVisibility.rawValue)
    }

    //MARK: - Unlocked Replies Tab
    func loadIndividualContacts(contacts: [User]) {
        self.clearValues(section: Section.individualContacts.rawValue)
        self.set(values: contacts,
                 cellClass: UserContactTableCell.self,
                 inSection: Section.individualContacts.rawValue)
    }


    //MARK: - Read Current Value Methods
//    func replyAtIndexPath(_ indexPath: IndexPath) -> PromptReply? {
//        return self[indexPath] as? PromptReply
//    }
//
//    func indexPath(forReplyRow row: Int) -> IndexPath {
//        return IndexPath(item: row, section: Section.replies.rawValue)
//    }

    //MARK: - Configure Cell
    override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
        switch (cell, value) {
        case let (cell as GeneralVisibilityTableCell, value as Visibility):
            cell.configureWith(value: value)
        case let (cell as UserContactTableCell, value as User):
            cell.configureWith(value: value)
        default:
            assertionFailure("Unrecognized combo: \(cell), \(value)")
        }
    }

}

