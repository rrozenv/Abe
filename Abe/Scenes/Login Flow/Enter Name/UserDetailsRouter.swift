
import Foundation
import UIKit

protocol UserDetailsRoutingLogic {
    func toPhoneEntry()
    func toPhoneInput()
}

final class UserDetailsRouter: UserDetailsRoutingLogic {
    
    private weak var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func toPhoneEntry() {
        let vc = PhoneEntryViewController()
        let router = PhoneEntryRouter(navigationController: navigationController!)
        let viewModel = PhoneEntryViewModel(userService: UserService(),
                                            router: router)
        vc.viewModel = viewModel
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func toPhoneInput() {
        let vc = PhoneInputViewController(isLogin: false)
        let router = PhoneEntryRouter(navigationController: navigationController!)
        vc.router = router
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
