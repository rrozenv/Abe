
import Foundation
import UIKit

protocol EnableContactsRoutingLogic {
    func toRoot()
    func toNameInput()
}

final class EnableContactsRouter: EnableContactsRoutingLogic {
    
    private weak var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func toRoot() {
        let vc = EnableContactsViewController()
        let viewModel = EnableContactsViewModel(contactService: ContactService(),
                                                contactsStore: ContactsStore(),
                                                router: self)
        vc.viewModel = viewModel
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func toNameInput() {
        let vc = UserDetailsViewController()
        let router = UserDetailsRouter(navigationController: navigationController!)
        let viewModel = UserDetailsViewModel(router: router)
        vc.viewModel = viewModel
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
