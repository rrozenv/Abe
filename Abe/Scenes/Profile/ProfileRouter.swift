
import Foundation
import UIKit

protocol ProfileRoutingLogic {
    func toHome()
}

class ProfileRouter: ProfileRoutingLogic {
    
    private weak var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func toHome() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
}
