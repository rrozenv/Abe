
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

    private let navigationController: UINavigationController
    //private weak var viewController: PromptsListViewController?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func toPrompts() {
        var vc = PromptsListViewController()
        let viewModel = PromptListViewModel(router: self)
        vc.setViewModelBinding(model: viewModel!)
        viewModel?.inputs.viewDidLoadInput.onNext(())
        navigationController.pushViewController(vc, animated: true)
    }

    func toCreatePrompt() {
        let navVc = UINavigationController()
        let router = CreatePromptRouter(navigationController: navVc)
        router.toMainInput()
        navigationController.present(navVc, animated: true, completion: nil)
        
//        let vc = CreatePromptViewController()
//        let navVc = UINavigationController(rootViewController: vc)
//        let router = CreatePromptRouter(navigationController: navVc)
//        let promptService = PromptService()
//        let viewModel = CreatePromptViewModel(promptService: promptService, router: router)
//        vc.viewModel = viewModel
//        navigationController.present(navVc, animated: true, completion: nil)
    }

    func toPrompt(_ prompt: Prompt) {
        let router = PromptDetailRouter(navigationController: navigationController)
        var viewCont = RepliesViewController()
        let vm = RepliesViewModel(router: router, prompt: prompt)
        viewCont.setViewModelBinding(model: vm!)
        navigationController.navigationBar.isHidden = true
        navigationController.pushViewController(viewCont, animated: true)
        
//        let router = PromptDetailRouter(navigationController: navigationController)
//        let commonRealm = RealmInstance(configuration: RealmConfig.common)
//        let privateRealm = RealmInstance(configuration: RealmConfig.secret)
//        let replyService = ReplyService()
//        let viewModel = PromptDetailViewModel(commonRealm: commonRealm,
//                                              privateRealm: privateRealm,
//                                              replyService: replyService,
//                                              prompt: prompt,
//                                              router: router)
//        let vc = PromptDetailViewController()
//        vc.viewModel = viewModel
//        navigationController.pushViewController(vc, animated: true)
    }

}

