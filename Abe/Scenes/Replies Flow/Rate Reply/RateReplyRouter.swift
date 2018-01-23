
import Foundation
import UIKit

protocol RateReplyRoutingLogic {
    func toPromptDetail()
    func toGuessReplyAuthorFor(reply: PromptReply, ratingScoreValue: Int)
}

final class RateReplyRouter: RateReplyRoutingLogic {
    
    weak private var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func toPromptDetail() {
        navigationController?.dismiss(animated: true)
    }
    
    func toGuessReplyAuthorFor(reply: PromptReply, ratingScoreValue: Int) {
        var vc = GuessReplyAuthorViewController()
        let router = GuessReplyAuthorRouter(navigationController: navigationController!)
        let viewModel = GuessReplyAuthorViewModel(reply: reply,
                                                  ratingScoreValue: ratingScoreValue,
                                                  router: router)
        vc.setViewModelBinding(model: viewModel!)
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
