
import Foundation
import UIKit

protocol PromptDetailRoutingLogic {
    func toPrompts()
    func toCreateReply(for prompt: Prompt)
    func toRateReply(reply: PromptReply, isCurrentUsersFriend: Bool)
    func toRatingsSummary(reply: PromptReply, userReplyScore: ReplyScore?)
}

final class PromptDetailRouter: PromptDetailRoutingLogic {
    
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func toPrompts() {
        navigationController.popViewController(animated: true)
    }
    
    func toCreateReply(for prompt: Prompt) {
        let navVc = UINavigationController()
        let router = CreateReplyRouter(navigationController: navVc)
        router.toMainInput(for: prompt)
        navigationController.present(navVc, animated: true, completion: nil)
    }
    
    func toRateReply(reply: PromptReply, isCurrentUsersFriend: Bool) {
        let navVc = UINavigationController()
        navVc.navigationBar.isHidden = true
        let router = RateReplyRouter(navigationController: navVc)
        var vc = RateReplyViewController()
        let viewModel = RateReplyViewModel(reply: reply, isCurrentUsersFriend: isCurrentUsersFriend, router: router)
        vc.setViewModelBinding(model: viewModel!)
        navVc.pushViewController(vc, animated: false)
        navigationController.present(navVc, animated: true, completion: nil)
    }
    
    func toRatingsSummary(reply: PromptReply,
                          userReplyScore: ReplyScore?) {
        guard let userScore = userReplyScore else { fatalError() }
        var vc = GuessAndWagerValidationViewController()
        let navVc = UINavigationController(rootViewController: vc)
        navVc.navigationBar.isHidden = true
        let router = GuessAndWagerValidationRouter(navigationController: navVc)
        let viewModel =
            GuessAndWagerValidationViewModel(reply: reply,
                                             isForSummaryOnly: true,
                                             replyScore: userScore,
                                             guessedUser: nil,
                                             wager: nil,
                                             router: router)
        vc.setViewModelBinding(model: viewModel!)
        viewModel?.inputs.viewDidLoadInput.onNext(())
        navigationController.present(navVc, animated: true, completion: nil)
    }
    
}
