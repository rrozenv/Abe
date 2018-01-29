
import Foundation
import UIKit

final class GuessReplyAuthorDataSource: ValueCellDataSource {
    
    var storedUsers: [IndividualContactViewModel] = []
    var latestFilteredUsers: [IndividualContactViewModel] = []
    var isFiltering: Bool = false
    
    func loadUsers(viewModels: [IndividualContactViewModel]) {
        self.storedUsers = viewModels
        self.set(values: viewModels,
                 cellClass: UserContactTableCell.self,
                 inSection: 0)
    }
    
    func filterUsersFor(searchText: String) {
        self.isFiltering = true
        let updatedViewModels = storedUsers.filter { $0.user.name.contains(searchText) }
        self.latestFilteredUsers = updatedViewModels
        self.set(values: updatedViewModels,
                 cellClass: UserContactTableCell.self,
                 inSection: 0)
    }
    
    func resetSearchFilter() {
        self.isFiltering = false
        self.latestFilteredUsers = []
        self.set(values: storedUsers,
                 cellClass: UserContactTableCell.self,
                 inSection: 0)
    }
    
    func toggleUser(_ viewModel: IndividualContactViewModel) -> IndexPath? {
        let allUsersIndex = storedUsers.index(of: viewModel)
        storedUsers[allUsersIndex!].isSelected = !storedUsers[allUsersIndex!].isSelected
        if let filteredUsersIndex = latestFilteredUsers.index(of: viewModel), isFiltering {
            latestFilteredUsers[filteredUsersIndex].isSelected = !latestFilteredUsers[filteredUsersIndex].isSelected
            self.set(value: latestFilteredUsers[filteredUsersIndex],
                     cellClass: UserContactTableCell.self,
                     inSection: 0,
                     row: Int(filteredUsersIndex))
            return IndexPath(row: Int(filteredUsersIndex), section: 0)
        } else if !isFiltering {
            self.set(value: storedUsers[allUsersIndex!],
                     cellClass: UserContactTableCell.self,
                     inSection: 0,
                     row: Int(allUsersIndex!))
            return IndexPath(row: Int(allUsersIndex!), section: 0)
        } else { return nil }
    }
    
    func getUser(at indexPath: IndexPath) -> IndividualContactViewModel? {
        if isFiltering {
            guard latestFilteredUsers.count > indexPath.row else { return nil }
            return latestFilteredUsers[indexPath.row]
        } else {
            return storedUsers[indexPath.row]
        }
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
