
import Foundation
import UIKit
import RealmSwift
import RxSwift
import RxCocoa
import RxRealm

final class Application {
    
    static let shared = Application()

    func configureMainInterface(in window: UIWindow) {
        if let _ = RealmAuth.isUserLoggedIn() {
            let promptsVc = PromptsListViewController()
            let navVc = UINavigationController()
            let router = PromptsRouter(navigationController: navVc)
            let realm = RealmInstance(configuration: RealmConfig.common)
            promptsVc.viewModel = PromptsListViewModel(realm: realm, router: router)
            window.rootViewController = navVc
            router.toPrompts()
        } else {
            let signupNavController = UINavigationController()
            let signupRouter = SignupRouter(window: window, navigationController: signupNavController)
            window.rootViewController = signupNavController
            signupRouter.toRegister()
        }
    }
    
    
}





