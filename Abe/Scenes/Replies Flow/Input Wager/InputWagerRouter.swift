
import Foundation
import UIKit

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
        navigationController?.dismiss(animated: true)
    }
    
}
