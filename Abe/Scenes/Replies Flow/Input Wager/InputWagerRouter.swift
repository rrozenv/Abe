
import Foundation
import UIKit
import RxSwift

protocol InputWagerRoutingLogic {
    func toGuessAndWagerValidation(reply: PromptReply, ratingScoreValue: Int, guessedUser: User, wager: Int)
}

final class InputWagerRouter: InputWagerRoutingLogic {
    
    weak private var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func toGuessAndWagerValidation(reply: PromptReply,
                                   ratingScoreValue: Int,
                                   guessedUser: User,
                                   wager: Int) {
        var vc = GuessAndWagerValidationViewController()
        let router = GuessAndWagerValidationRouter(navigationController: navigationController!)
        let viewModel = GuessAndWagerValidationViewModel(reply: reply,
                                                         ratingScoreValue: ratingScoreValue,
                                                         guessedUser: guessedUser,
                                                         wager: wager,
                                                         router: router)
        vc.setViewModelBinding(model: viewModel!)
        viewModel?.inputs.viewDidLoadInput.onNext(())
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
