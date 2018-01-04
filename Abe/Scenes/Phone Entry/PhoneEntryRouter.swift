
import Foundation
import UIKit

protocol PhoneEntryRoutingLogic {
    func toHome()
}

class PhoneEntryRouter: PhoneEntryRoutingLogic {
    
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func toHome() {
        let promptsVc = PromptsListViewController()
        let navVc = UINavigationController()
        let router = PromptsRouter(navigationController: navVc,
                                   viewController: promptsVc)
        let realm = RealmInstance(configuration: RealmConfig.common)
        promptsVc.viewModel = PromptsListViewModel(realm: realm, router: router)
        UIApplication.shared.keyWindow!.rootViewController = navVc
        router.toPrompts()
    }
    
}
