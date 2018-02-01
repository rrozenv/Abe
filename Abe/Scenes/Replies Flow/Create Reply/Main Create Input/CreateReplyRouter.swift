
import Foundation
import UIKit

protocol CreateReplyRoutingLogic {
    func toMainInput(for prompt: Prompt)
    func toReplyOptions(with savedInput: SavedReplyInput)
    func toPromptDetail()
}

final class CreateReplyRouter: CreateReplyRoutingLogic {
    
    weak private var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func toMainInput(for prompt: Prompt) {
        let vc = CreatePromptReplyViewController()
        vc.viewModel = CreateReplyViewModel(prompt: prompt, router: self)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func toReplyOptions(with savedInput: SavedReplyInput) {
        var vc = ReplyVisibilityViewController()
        let router = ReplyOptionsRouter(navigationController: navigationController!)
        let viewModel = ReplyVisibilityViewModel(router: router,
                                                 prompt: savedInput.prompt,
                                                 savedReplyInput: savedInput,
                                                 isForReply: true)
        
        vc.setViewModelBinding(model: viewModel!)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func toPromptDetail() {
        navigationController?.dismiss(animated: true)
    }
    
}
