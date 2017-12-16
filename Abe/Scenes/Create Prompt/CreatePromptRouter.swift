
import Foundation
import UIKit

protocol CreatePromptRoutingLogic {
    func toPrompts()
}

final class CreatePromptRouter: CreatePromptRoutingLogic {
    private let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func toPrompts() {
        navigationController.dismiss(animated: true)
    }
}

