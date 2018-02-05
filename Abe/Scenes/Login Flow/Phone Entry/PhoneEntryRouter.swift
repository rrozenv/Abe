
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
        NotificationCenter.default.post(name: .closeLoginVC, object: nil)
//        let navVc = UINavigationController()
//        let router = PromptsRouter(navigationController: navVc)
//        UIApplication.shared.keyWindow!.rootViewController = navVc
//        router.toPrompts()
    }
    
}
