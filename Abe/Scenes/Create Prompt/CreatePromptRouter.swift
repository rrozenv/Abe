
import Foundation
import UIKit

protocol CreatePromptRoutingLogic {
    func toMainInput()
    func toPrompts()
}

final class CreatePromptRouter: CreatePromptRoutingLogic {
    private let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func toMainInput() {
        let vc = CreatePromptViewController()
        let promptService = PromptService()
        let userService = UserService()
        vc.viewModel = CreatePromptViewModel(promptService: promptService, userService: userService, router: self)
        navigationController.pushViewController(vc, animated: true)
    }

    func toPrompts() {
        navigationController.dismiss(animated: true)
    }
}

