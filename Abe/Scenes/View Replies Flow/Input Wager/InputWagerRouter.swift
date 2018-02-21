
import Foundation
import UIKit
import RxSwift

protocol InputWagerRoutingLogic {
    func toGuessAndWagerValidation(reply: PromptReply, replyScore: ReplyScore, guessedUser: User, wager: Int)
    func toPreviousNavViewController()
}

final class InputWagerRouter: InputWagerRoutingLogic {
    
    weak private var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func toGuessAndWagerValidation(reply: PromptReply,
                                   replyScore: ReplyScore,
                                   guessedUser: User,
                                   wager: Int) {
        var vc = GuessAndWagerValidationViewController()
        let router = GuessAndWagerValidationRouter(navigationController: navigationController!)
        let viewModel = GuessAndWagerValidationViewModel(reply: reply,
                                                         replyScore: replyScore,
                                                         guessedUser: guessedUser,
                                                         wager: wager,
                                                         router: router)
        vc.setViewModelBinding(model: viewModel!)
        viewModel?.inputs.viewDidLoadInput.onNext(())
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func toPreviousNavViewController() {
        navigationController?.popViewController(animated: true)
    }
    
}
