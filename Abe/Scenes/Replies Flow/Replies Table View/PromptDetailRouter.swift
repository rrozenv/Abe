
import Foundation
import UIKit

protocol PromptDetailRoutingLogic {
    func toPrompts()
    func toCreateReply(for prompt: Prompt)
    func toRateReply(for reply: PromptReply)
}

final class PromptDetailRouter: PromptDetailRoutingLogic {
    
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func toPrompts() {
        navigationController.navigationBar.isHidden = false
        navigationController.popViewController(animated: true)
    }
    
    func toCreateReply(for prompt: Prompt) {
        let navVc = UINavigationController()
        let router = CreateReplyRouter(navigationController: navVc)
        router.toMainInput(for: prompt)
        navigationController.present(navVc, animated: true, completion: nil)
    }
    
    func toRateReply(for reply: PromptReply) {
        var vc = RateReplyViewController()
        let viewModel = RateReplyViewModel(reply: reply)
        vc.setViewModelBinding(model: viewModel)
        navigationController.present(vc, animated: true, completion: nil)
    }
    
}
