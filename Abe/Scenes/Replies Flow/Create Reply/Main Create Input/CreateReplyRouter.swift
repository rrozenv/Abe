
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
        let vc = ReplyOptionsViewController()
        let privateRealm = RealmInstance(configuration: RealmConfig.secret)
        let router = ReplyOptionsRouter(navigationController: navigationController!)
        let replyService = ReplyService()
        let viewModel = ReplyOptionsViewModel(replyService: replyService,                   privateRealm: privateRealm,
                                              prompt: savedInput.prompt,
                                              savedReplyInput: savedInput,
                                              router: router)
        vc.viewModel = viewModel
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func toPromptDetail() {
        navigationController?.dismiss(animated: true)
    }
    
}
