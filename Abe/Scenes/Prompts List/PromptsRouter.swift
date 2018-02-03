
import Foundation
import UIKit
import RxSwift
import RxCocoa
import RealmSwift

protocol PromptsRoutingLogic {
    func toCreatePrompt()
    func toPrompt(_ prompt: Prompt)
    func toPrompts()
}

class PromptsRouter: PromptsRoutingLogic {

    private var navigationController: UINavigationController?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func toPrompts() {
        var vc = PromptsListViewController()
        let viewModel = PromptListViewModel(router: self)
        vc.setViewModelBinding(model: viewModel!)
        viewModel?.inputs.viewDidLoadInput.onNext(())
        navigationController?.pushViewController(vc, animated: true)
    }

    func toCreatePrompt() {
        let navVc = UINavigationController()
        let router = CreatePromptRouter(navigationController: navVc)
        router.toMainInput()
        navigationController?.present(navVc, animated: true, completion: nil)
    }

    func toPrompt(_ prompt: Prompt) {
        let router = PromptDetailRouter(navigationController: navigationController!)
        var viewCont = RepliesViewController()
        let vm = RepliesViewModel(router: router, prompt: prompt)
        viewCont.setViewModelBinding(model: vm!)
        navigationController?.navigationBar.isHidden = true
        navigationController?.pushViewController(viewCont, animated: true)
    }

}

