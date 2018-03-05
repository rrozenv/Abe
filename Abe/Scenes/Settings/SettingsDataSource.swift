
import Foundation
import UIKit

enum SettingType: String {
    case feedback = "Feedback"
    case share = "Share"
    case logout = "Logout"
}

struct Setting {
    let type: SettingType
    let iconImage: UIImage?
    let action: () -> Void
}

final class SettingsDataSource: ValueCellDataSource {
    
    func load(settings: [Setting]) {
        self.set(values: settings,
                 cellClass: SettingCell.self,
                 inSection: 0)
    }
    
    func settingAtIndexPath(_ indexPath: IndexPath) -> Setting? {
        return self[indexPath] as? Setting
    }

    override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
        switch (cell, value) {
        case let (cell as SettingCell, value as Setting):
            cell.configureWith(value: value)
        default:
            assertionFailure("Unrecognized combo: \(cell), \(value)")
        }
    }
    
}
