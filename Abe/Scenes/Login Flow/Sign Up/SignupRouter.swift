
import Foundation
import UIKit
import RxSwift

protocol SignupRoutingLogic {
    func toRegister()
    func toHome()
}

class SignupRouter: SignupRoutingLogic {
    
    private let window: UIWindow
    private let navigationController: UINavigationController
    
    init(window: UIWindow, navigationController: UINavigationController) {
        self.window = window
        self.navigationController = navigationController
    }
    
    func toRegister() {
        let vc = SignUpViewController()
        vc.viewModel = SignupViewModel(userService: UserService(), router: self)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func toHome() {
        var promptsVc = PromptsListViewController()
        let navVc = UINavigationController()
        let router = PromptsRouter(navigationController: navVc)
        let vm = PromptListViewModel(router: router)
        promptsVc.setViewModelBinding(model: vm!)
        window.rootViewController = navVc
        router.toPrompts()
    }
    
}

