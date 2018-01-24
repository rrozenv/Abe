
import Foundation
import UIKit

protocol GuessReplyAuthorRoutingLogic {
    func toInputWagerWith(selectedUser: User, ratingScoreValue: Int, reply: PromptReply)
}

final class GuessReplyAuthorRouter: GuessReplyAuthorRoutingLogic {
    
    weak private var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func toInputWagerWith(selectedUser: User, ratingScoreValue: Int, reply: PromptReply) {
        var vc = InputWagerViewController()
        let router = InputWagerRouter(navigationController: navigationController!)
        let viewModel = InputWagerViewModel(reply: reply,
                                            guessedUser: selectedUser,
                                            ratingScoreValue: ratingScoreValue,
                                            router: router)
        vc.setViewModelBinding(model: viewModel!)
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
