
import Foundation
import UIKit

protocol SignupLoginRoutingLogic {
    func toRoot()
    func toSignupFlow()
    func toLoginFlow()
}

final class SignupLoginRouter: SignupLoginRoutingLogic {

    private weak var navigationController: UINavigationController?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func toRoot() {
        var vc = SignupLoginViewController()
        let viewModel = SignupLoginViewModel(router: self)
        vc.setViewModelBinding(model: viewModel)
        navigationController?.pushViewController(vc, animated: true)
    }

    func toSignupFlow() {
        let vc = EnableContactsViewController()
        let router = EnableContactsRouter(navigationController: navigationController!)
        let viewModel = EnableContactsViewModel(router: router)
        vc.viewModel = viewModel
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func toLoginFlow() {
        let vc = PhoneInputViewController(isLogin: true)
        let router = PhoneEntryRouter(navigationController: navigationController!)
        vc.router = router
        navigationController?.pushViewController(vc, animated: true)
    }

}

