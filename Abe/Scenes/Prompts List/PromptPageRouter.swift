
import Foundation
import UIKit

protocol PromptPageRoutingLogic {
    //func toRoot()
    func toCreatePrompt()
}

class PromptPageRouter: PromptPageRoutingLogic {
    
    private weak var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
//    func toRoot() {
//        let pageVc = PromptPageViewController()
//        let viewModel = PromptPageViewModel(router: self)
//        navigationController?.pushViewController(pageVc, animated: true)
//
//        var vc = PromptsListViewController()
//        let viewModel = PromptListViewModel(router: self)
//        vc.setViewModelBinding(model: viewModel!)
//        viewModel?.inputs.viewDidLoadInput.onNext(())
//        navigationController?.pushViewController(vc, animated: true)
//    }
    
    func toCreatePrompt() {
        let navVc = UINavigationController()
        let router = CreatePromptRouter(navigationController: navVc)
        router.toMainInput()
        navigationController?.present(navVc, animated: true, completion: nil)
    }
    
}
