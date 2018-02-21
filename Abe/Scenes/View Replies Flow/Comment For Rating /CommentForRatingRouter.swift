
import Foundation
import UIKit

protocol CommentForRatingRoutingLogic {
    func toPreviousViewController()
    func toGuessReplyAuthorFor(reply: PromptReply, replyScore: ReplyScore)
    func toSummary(reply: PromptReply, replyScore: ReplyScore)
}

final class CommentForRatingRouter: CommentForRatingRoutingLogic {
    
    weak private var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func toPreviousViewController() {
        navigationController?.popViewController(animated: true)
    }
    
    func toGuessReplyAuthorFor(reply: PromptReply, replyScore: ReplyScore) {
        var vc = GuessReplyAuthorViewController()
        let router = GuessReplyAuthorRouter(navigationController: navigationController!)
        let viewModel = GuessReplyAuthorViewModel(reply: reply,
                                                  replyScore: replyScore,
                                                  router: router)
        vc.setViewModelBinding(model: viewModel!)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func toSummary(reply: PromptReply, replyScore: ReplyScore) {
        var vc = GuessAndWagerValidationViewController()
        let router = GuessAndWagerValidationRouter(navigationController: navigationController!)
        let viewModel = GuessAndWagerValidationViewModel(reply: reply,
                                                         replyScore: replyScore,
                                                         guessedUser: nil,
                                                         wager: nil,
                                                         router: router)
        vc.setViewModelBinding(model: viewModel!)
        viewModel?.inputs.viewDidLoadInput.onNext(())
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
