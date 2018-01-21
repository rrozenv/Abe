
import Foundation
import UIKit

protocol RateReplyRoutingLogic {
    func toPromptDetail()
}

final class RateReplyRouter: RateReplyRoutingLogic {
    
    weak private var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func toPromptDetail() {
        navigationController?.dismiss(animated: true)
    }
    
}
