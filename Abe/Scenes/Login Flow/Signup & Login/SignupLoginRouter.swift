
import Foundation
import UIKit

protocol SignupLoginRoutingLogic {
    func toRoot()
    func toSignupFlow()
    func toLoginFlow()
    func toOnboardingFlow()
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
        viewModel.inputs.viewDidLoadInput.onNext(())
        navigationController?.isNavigationBarHidden = true
        navigationController?.pushViewController(vc, animated: true)
    }

    func toSignupFlow() {
        var vc = EnableContactsViewController()
        let router = EnableContactsRouter(navigationController: navigationController!)
        let viewModel = AllowContactsViewModel(router: router)
        vc.setViewModelBinding(model: viewModel)
        viewModel.inputs.viewDidLoadInput.onNext(())
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func toLoginFlow() {
        let vc = PhoneInputViewController(isLogin: true)
        let router = PhoneEntryRouter(navigationController: navigationController!)
        vc.router = router
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func toOnboardingFlow() {
        let vc = OnboardingPageViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

}

