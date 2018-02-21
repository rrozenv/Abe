
import Foundation
import UIKit

protocol GuessAndWagerValidationRoutingLogic {
    func toPromptDetail()
}

final class GuessAndWagerValidationRouter: GuessAndWagerValidationRoutingLogic {
    
    weak private var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func toPromptDetail() {
        navigationController?.dismiss(animated: true)
    }
    
}
