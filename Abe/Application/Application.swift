
import Foundation
import UIKit
import RealmSwift
import RxSwift
import RxCocoa
import RxRealm
import RxSwiftExt

final class Application {
    
    static let shared = Application(userService: UserService())
    private let userService: UserService
    private let disposeBag = DisposeBag()
    var currentUser: User? = nil
    
    private init(userService: UserService) {
        self.userService = userService
    }

    func configureMainInterface(in window: UIWindow) {
        let user = RealmAuth.fetchSyncUser().share()
        
        //MARK: - If user is logged in
        _ = user
            .unwrap()
            .flatMapLatest { [unowned self] in
                self.userService.fetchUserFor(key: $0.identity!)
            }
            .do(onNext: { [unowned self] (user) in
                self.currentUser = user
                self.displayHomeViewController(in: window)
            })
            .subscribe()
            .disposed(by: disposeBag)
        
        //MARK: - If user is NOT logged in
        _ = user
            .filter { $0 == nil }
            .do(onNext: { [unowned self] _ in
                self.displayRegisterViewController(in: window)
            })
            .subscribe()
            .disposed(by: disposeBag)
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





