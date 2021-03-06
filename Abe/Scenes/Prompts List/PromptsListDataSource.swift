
import Foundation
import UIKit

final class PromptListDataSource: ValueCellDataSource {

    private var currentTabVisibility = Visibility.all
    
    enum Section: Int {
        case contactsOnly
        case publicOnly
    }
    
    func load(prompts: [Prompt]) {
        self.currentTabVisibility = .all
        self.set(values: prompts,
                 cellClass: PromptTableCell.self,
                 inSection: 0)
    }
    
    func add(prompts: [Prompt]) {
        prompts.forEach {
            self.prependRow(value: $0,
                            cellClass: PromptTableCell.self,
                            toSection: 0)
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
