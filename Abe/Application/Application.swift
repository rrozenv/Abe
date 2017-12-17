
import Foundation
import UIKit
import RealmSwift
import RxSwift
import RxCocoa
import RxRealm

final class Application {
    
    static let shared = Application()

    func configureMainInterface(in window: UIWindow) {
        if RealmAuth.fetchCurrentSyncUser() != nil {
            self.displayHomeViewController(in: window)
        } else {
            self.displayRegisterViewController(in: window)
        }
    }
    
    private func displayHomeViewController(in window: UIWindow) {
        let navVc = UINavigationController()
        let promptsVc = PromptsListViewController()
        let router = PromptsRouter(navigationController: navVc)
        let realm = RealmInstance(configuration: RealmConfig.common)
        promptsVc.viewModel = PromptsListViewModel(realm: realm, router: router)
        window.rootViewController = navVc
        router.toPrompts()
    }
    
    private func displayRegisterViewController(in window: UIWindow) {
        let signupNavController = UINavigationController()
        let signupRouter = SignupRouter(window: window, navigationController: signupNavController)
        window.rootViewController = signupNavController
        signupRouter.toRegister()
    }
    
}





