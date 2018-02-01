
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
    
    func selectedCount() -> Int {
        return storedUsers.filter { $0.isSelected }.count
    }
    
    func totalCount() -> Int {
        return self.numberOfItems()
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
    
    func toggleAll(shouldSelect: Bool) {
        let allUpdatedUsers = storedUsers
            .map { inputs -> IndividualContactViewModel in
                return IndividualContactViewModel(isSelected: shouldSelect ? true : false, user: inputs.user)
        }
        self.storedUsers = allUpdatedUsers
        if isFiltering {
            let filteredUpdatedUsers = latestFilteredUsers
                .map { inputs -> IndividualContactViewModel in
                    return IndividualContactViewModel(isSelected: shouldSelect ? true : false, user: inputs.user)
            }
            self.latestFilteredUsers = filteredUpdatedUsers
            self.set(values: filteredUpdatedUsers,
                     cellClass: UserContactTableCell.self,
                     inSection: 0)
        } else {
            self.set(values: allUpdatedUsers,
                     cellClass: UserContactTableCell.self,
                     inSection: 0)
        }
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
