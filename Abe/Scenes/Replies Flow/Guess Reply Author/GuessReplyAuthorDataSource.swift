
import Foundation
import UIKit

final class GuessReplyAuthorDataSource: ValueCellDataSource {
    
    func loadUsers(ratings: [IndividualContactViewModel]) {
        self.set(values: ratings,
                 cellClass: UserContactTableCell.self,
                 inSection: 0)
    }
    
    func toggleUser(at indexPath: IndexPath) {
        guard var viewModel = self.user(at: indexPath) else { return }
        viewModel.isSelected = !viewModel.isSelected
        self.set(value: viewModel,
                 cellClass: UserContactTableCell.self,
                 inSection: 0,
                 row: indexPath.row)
    }
    
    func user(at indexPath: IndexPath) -> IndividualContactViewModel? {
        return self[indexPath] as? IndividualContactViewModel
    }
    
    //MARK: - Configure Cell
    override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
        switch (cell, value) {
        case let (cell as UserContactTableCell, value as IndividualContactViewModel):
            cell.configureWith(value: value)
        default:
            assertionFailure("Unrecognized combo: \(cell), \(value)")
        }
    }
    
}
