
import Foundation
import UIKit

protocol GuessReplyAuthorRoutingLogic {
    func toInputWagerWith(selectedUser: User)
}

final class GuessReplyAuthorRouter: GuessReplyAuthorRoutingLogic {
    
    weak private var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func toInputWagerWith(selectedUser: User) {
        print("selected user: \(selectedUser.name)")
        navigationController?.dismiss(animated: true)
    }
    
}
