
import Foundation
import UIKit

protocol GuessReplyAuthorRoutingLogic {
    func toPreviousNavViewController()
    func toInputWagerWith(selectedUser: User, replyScore: ReplyScore, reply: PromptReply)
}

final class GuessReplyAuthorRouter: GuessReplyAuthorRoutingLogic {
    
    weak private var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func toInputWagerWith(selectedUser: User, replyScore: ReplyScore, reply: PromptReply) {
        var vc = InputWagerViewController()
        let router = InputWagerRouter(navigationController: navigationController!)
        let viewModel = InputWagerViewModel(reply: reply,
                                            guessedUser: selectedUser,
                                            replyScore: replyScore,
                                            router: router)
        vc.setViewModelBinding(model: viewModel!)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func toPreviousNavViewController() {
        navigationController?.popViewController(animated: true)
    }
    
}
