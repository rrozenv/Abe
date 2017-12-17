
import Foundation
import UIKit

protocol CreateReplyRoutingLogic {
    func toMainInput(for prompt: Prompt)
    func toPromptDetail()
}

final class CreateReplyRouter: CreateReplyRoutingLogic {
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func toMainInput(for prompt: Prompt) {
        let vc = CreatePromptReplyViewController()
        let realm = RealmInstance(configuration: RealmConfig.common)
        vc.viewModel = CreateReplyViewModel(realm: realm, prompt: prompt, router: self)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func toPromptDetail() {
        navigationController.dismiss(animated: true)
    }
}
