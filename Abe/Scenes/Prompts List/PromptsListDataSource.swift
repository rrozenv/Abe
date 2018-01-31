
import Foundation
import UIKit

final class PromptListDataSource: ValueCellDataSource {
    
    enum Section: Int {
        case contactsOnly
        case publicOnly
    }
    
    func loadContactsOnly(prompts: [Prompt]) {
        //guard prompts.isNotEmpty else { return }
        self.set(values: prompts,
                 cellClass: PromptTableCell.self,
                 inSection: Section.contactsOnly.rawValue)
    }
    
    func loadPublic(prompts: [Prompt]) {
        self.set(values: prompts,
                 cellClass: PromptTableCell.self,
                 inSection: Section.publicOnly.rawValue)
    }
    
    func addNewPublic(prompts: [Prompt]) {
        prompts.forEach {
            self.prependRow(value: $0,
                            cellClass: PromptTableCell.self,
                            toSection: Section.publicOnly.rawValue)
        }
    }
    
    func updatePrompt(_ prompt: Prompt, at indexPath: IndexPath) {
        self.set(value: prompt,
                 cellClass: PromptTableCell.self,
                 inSection: indexPath.section,
                 row: indexPath.row)
    }
    
    //MARK: - Read Current Value Methods
    func promptAtIndexPath(_ indexPath: IndexPath) -> Prompt? {
        return self[indexPath] as? Prompt
    }
    
    //MARK: - Configure Cell
    override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
        switch (cell, value) {
        case let (cell as PromptTableCell, value as Prompt):
            cell.configureWith(value: value)
        default:
            assertionFailure("Unrecognized combo: \(cell), \(value)")
        }
    }
    
}
