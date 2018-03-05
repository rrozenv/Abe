
import Foundation
import UIKit

protocol EnableContactsRoutingLogic {
    func toRoot()
    func toNameInput()
    func toPreviousVc()
}

final class EnableContactsRouter: EnableContactsRoutingLogic {
    
    private weak var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func toRoot() {
        var vc = EnableContactsViewController()
        let viewModel = AllowContactsViewModel(router: self)
        vc.setViewModelBinding(model: viewModel)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func toNameInput() {
        var vc = UserDetailsViewController()
        let router = UserDetailsRouter(navigationController: navigationController!)
        let viewModel = UserDetailsViewModel(router: router)
        vc.setViewModelBinding(model: viewModel)
        viewModel.inputs.viewDidLoadInput.onNext(())
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func toPreviousVc() {
        navigationController?.popViewController(animated: true)
    }
    
}
