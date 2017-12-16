
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
        let router = CreatePromptRouter(navigationController: navigationController)
        let realm = RealmInstance(configuration: RealmConfig.common)
        let viewModel = CreatePromptViewModel(realm: realm, router: router)
        let vc = CreatePromptViewController()
        vc.viewModel = viewModel
        let nc = UINavigationController(rootViewController: vc)
        navigationController.present(nc, animated: true, completion: nil)
    }

    func toPrompt(_ prompt: Prompt) {
//        let router = PromptDetailRouter(dataProvider: dataProvider,
//                                        navigationController: navigationController)
//
//        let viewModel = PromptDetailViewModel(promptDataStorage: dataProvider.makePromptsDataService(),prompt: prompt, router: router)
//
//        let vc = PromptDetailViewController()
//        vc.viewModel = viewModel
//        navigationController.pushViewController(vc, animated: true)
    }

}

