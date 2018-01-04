
import Foundation
import UIKit

protocol UserDetailsRoutingLogic {
    func toPhoneEntry()
}

final class UserDetailsRouter: UserDetailsRoutingLogic {
    
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func toPhoneEntry() {
        let vc = PhoneEntryViewController()
        let viewModel = PhoneEntryViewModel(userService: UserService())
        vc.viewModel = viewModel
        navigationController.pushViewController(vc, animated: true)
    }
    
}
