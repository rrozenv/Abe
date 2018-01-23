
import Foundation
import UIKit

final class ReplyVisibilityDataSource: ValueCellDataSource {

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

    //MARK: - Unlocked Replies Tab
    func loadIndividualContacts(contacts: [IndividualContactViewModel]) {
        self.set(values: contacts,
                 cellClass: UserContactTableCell.self,
                 inSection: 0)
    }

    //MARK: - Read Current Value Methods
    func toggleContact(at indexPath: IndexPath) {
        guard var viewModel = contactViewModelAt(indexPath: indexPath) else { return }
        viewModel.isSelected = !viewModel.isSelected
        self.set(value: viewModel,
                 cellClass: UserContactTableCell.self,
                 inSection: indexPath.section,
                 row: indexPath.row)
    }
    
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
    
    func toggleAll(shouldSelect: Bool) {
        guard let viewModels = self[section: 0] as? [IndividualContactViewModel] else { return }
        let updatedViewModels = viewModels
            .map { inputs -> IndividualContactViewModel in
                return IndividualContactViewModel(isSelected: shouldSelect ? true : false, user: inputs.user)
            }
        self.set(values: updatedViewModels,
                 cellClass: UserContactTableCell.self,
                 inSection: 0)
    }
    
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

    func contactViewModelAt(indexPath: IndexPath) -> IndividualContactViewModel? {
        return self[indexPath] as? IndividualContactViewModel
    }

    //MARK: - Configure Cell
    override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
        switch (cell, value) {
        case let (cell as GeneralVisibilityTableCell, value as VisibilityCellViewModel):
            cell.configureWith(value: value)
        case let (cell as UserContactTableCell, value as IndividualContactViewModel):
            cell.configureWith(value: value)
        default:
            assertionFailure("Unrecognized combo: \(cell), \(value)")
        }
    }

}

