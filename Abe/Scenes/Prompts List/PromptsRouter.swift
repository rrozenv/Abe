
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

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func toPrompts() {
        let vc = PromptsListViewController()
        let realm = RealmInstance(configuration: RealmConfig.common)
        vc.viewModel = PromptsListViewModel(realm: realm, router: self)
        navigationController.pushViewController(vc, animated: true)
    }

    func toCreatePrompt() {
        let navVc = UINavigationController()
        let router = CreatePromptRouter(navigationController: navVc)
        let realm = RealmInstance(configuration: RealmConfig.common)
        let viewModel = CreatePromptViewModel(realm: realm, router: router)
        let vc = CreatePromptViewController()
        vc.viewModel = viewModel
        navigationController.present(navVc, animated: true, completion: nil)
        router.toMainInput()
    }

    func toPrompt(_ prompt: Prompt) {
        let router = PromptDetailRouter(navigationController: navigationController)
        let realm = RealmInstance(configuration: RealmConfig.common)
        let viewModel = PromptDetailViewModel(realm: realm, prompt: prompt, router: router)
        let vc = PromptDetailViewController()
        vc.viewModel = viewModel
        navigationController.pushViewController(vc, animated: true)
    }

}

