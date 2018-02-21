
import Foundation
import UIKit

protocol ImageSearchRoutingLogic {
    func toMainCreateReplyInput()
}

final class ImageSearchRouter: ImageSearchRoutingLogic {
    
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func toMainCreateReplyInput() {
        navigationController.isNavigationBarHidden = true
        navigationController.popViewController(animated: true)
    }
    
}
