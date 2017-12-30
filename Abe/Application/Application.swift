
import Foundation
import UIKit
import RealmSwift
import RxSwift
import RxCocoa
import RxRealm

final class Application {
    
    static let shared = Application()
    var currentUser: User? = nil
    
    private init() { }

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
        let router = PromptsRouter(navigationController: navVc,
                                   viewController: promptsVc)
        let realm = RealmInstance(configuration: RealmConfig.common)
        promptsVc.viewModel = PromptsListViewModel(realm: realm, router: router)
        router.toPrompts()
        window.rootViewController = navVc
    }
    
    private func displayRegisterViewController(in window: UIWindow) {
        let signupNavController = UINavigationController()
        let signupRouter = SignupRouter(window: window, navigationController: signupNavController)
        signupRouter.toRegister()
        window.rootViewController = signupNavController
    }
    
}





