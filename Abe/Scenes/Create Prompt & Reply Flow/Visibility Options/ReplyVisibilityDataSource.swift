
import Foundation
import UIKit

final class ReplyVisibilityDataSource: ValueCellDataSource {
    
    enum Section: Int {
        case publicVisibility
        case contacts
    }

    private var storedUsers: [IndividualContactViewModel] = []
    private var latestFilteredUsers: [IndividualContactViewModel] = []
    private var isFiltering: Bool = false
    
    func loadUsers(viewModels: [IndividualContactViewModel]) {
        self.storedUsers = viewModels
        self.set(values: viewModels,
                 cellClass: UserContactTableCell.self,
                 inSection: Section.contacts.rawValue)
    }
    
    func filterUsersFor(searchText: String) {
        self.isFiltering = true
        let updatedViewModels = storedUsers.filter { $0.user.name.contains(searchText) }
        self.latestFilteredUsers = updatedViewModels
        self.set(values: updatedViewModels,
                 cellClass: UserContactTableCell.self,
                 inSection: Section.contacts.rawValue)
    }
    
    func resetSearchFilter() {
        self.isFiltering = false
        self.latestFilteredUsers = []
        self.set(values: storedUsers,
                 cellClass: UserContactTableCell.self,
                 inSection: Section.contacts.rawValue)
    }
    
    func selectedCount() -> Int {
        return storedUsers.filter { $0.isSelected }.count
    }
    
    func totalCount() -> Int {
        return isFiltering ? self.numberOfItems() : storedUsers.count
    }
    
    func toggleUser(_ viewModel: IndividualContactViewModel) -> IndexPath? {
        guard let allUsersIndex = storedUsers.index(of: viewModel)
            else { return nil }
        storedUsers[allUsersIndex].isSelected = !storedUsers[allUsersIndex].isSelected
        if let filteredUsersIndex = latestFilteredUsers.index(of: viewModel), isFiltering {
            latestFilteredUsers[filteredUsersIndex].isSelected = !latestFilteredUsers[filteredUsersIndex].isSelected
            self.set(value: latestFilteredUsers[filteredUsersIndex],
                     cellClass: UserContactTableCell.self,
                     inSection: Section.contacts.rawValue,
                     row: Int(filteredUsersIndex))
            return IndexPath(row: Int(filteredUsersIndex), section: Section.contacts.rawValue)
        } else if !isFiltering {
            self.set(value: storedUsers[allUsersIndex],
                     cellClass: UserContactTableCell.self,
                     inSection: Section.contacts.rawValue,
                     row: Int(allUsersIndex))
            return IndexPath(row: Int(allUsersIndex), section: Section.contacts.rawValue)
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
                     inSection: Section.contacts.rawValue)
        } else {
            self.set(values: allUpdatedUsers,
                     cellClass: UserContactTableCell.self,
                     inSection: Section.contacts.rawValue)
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

//    enum Section: Int {
//        case generalVisibility
//        case individualContacts
//    }

//MARK: - Locked Replies Tab
//    func loadGeneralVisibility(options: [VisibilityCellViewModel]) {
//        //self.clearValues(section: Section.generalVisibility.rawValue)
//        self.set(values: options,
//                 cellClass: GeneralVisibilityTableCell.self,
//                 inSection: Section.generalVisibility.rawValue)
//    }

//    func updateGeneralVisibilitySelectedStatus(at indexPath: IndexPath) {
//        //Updated General Section
//        guard let visViewModels = self[section: Section.generalVisibility.rawValue] as? [VisibilityCellViewModel] else { return }
//        let updatedGeneralVisViewModels = visViewModels.enumerated()
//            .map { inputs -> VisibilityCellViewModel in
//                var vm = VisibilityCellViewModel(isSelected: false, visibility: inputs.element.visibility)
//                vm.isSelected = inputs.offset == indexPath.row ? true : false
//                return vm
//        }
//        self.set(values: updatedGeneralVisViewModels,
//                 cellClass: GeneralVisibilityTableCell.self,
//                 inSection: Section.generalVisibility.rawValue)
//
//        //Update Individual Section
//        guard let contactViewModels = self[section: Section.individualContacts.rawValue] as? [IndividualContactViewModel] else { return }
//        let updatedContactViewModels = contactViewModels.map {
//            IndividualContactViewModel(isSelected: false, user: $0.user)
//        }
//        self.set(values: updatedContactViewModels,
//                 cellClass: UserContactTableCell.self,
//                 inSection: Section.individualContacts.rawValue)
//    }



//    func deselectAllInSection(section: Section) {
//        switch section {
//        case .generalVisibility:
//            guard let visViewModels = self[section: section.rawValue] as? [VisibilityCellViewModel] else { return }
//            var shouldReload = false
//            let updatedGeneralVisViewModels = visViewModels.map { vm -> VisibilityCellViewModel in
//                    if vm.isSelected { shouldReload = true }
//                    return VisibilityCellViewModel(isSelected: false, visibility: vm.visibility)
//                }
//            guard shouldReload else { return }
//            self.set(values: updatedGeneralVisViewModels,
//                     cellClass: GeneralVisibilityTableCell.self,
//                     inSection: Section.generalVisibility.rawValue)
//        default: break
//        }
//    }

//    func selectGeneralVisibility(_ vis: Visibility) {
//        let indexPath = IndexPath(row: 0, section: Section.generalVisibility.rawValue)
//        guard var viewModel = generalVisAtIndexPath(indexPath) else { return }
//        viewModel.isSelected = !viewModel.isSelected
//        self.set(value: viewModel,
//                 cellClass: GeneralVisibilityTableCell.self,
//                 inSection: Section.generalVisibility.rawValue,
//                 row: 0)
//    }
//
//    func generalVisAtIndexPath(_ indexPath: IndexPath) -> VisibilityCellViewModel? {
//        return self[indexPath] as? VisibilityCellViewModel
//    }


