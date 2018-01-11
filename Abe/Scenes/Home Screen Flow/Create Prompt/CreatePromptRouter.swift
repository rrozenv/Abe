
import Foundation
import UIKit

protocol CreatePromptRoutingLogic {
    func toMainInput()
    func toPrompts()
}

final class CreatePromptRouter: CreatePromptRoutingLogic {
    private let navigationController: UINavigationController
    weak var createPromptViewModel: CreatePromptViewModel?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func toMainInput() {
        let vc = CreatePromptViewController()
        let promptService = PromptService()
        let viewModel = CreatePromptViewModel(promptService: promptService, router: self)
        vc.viewModel = viewModel
        self.createPromptViewModel = viewModel
        navigationController.pushViewController(vc, animated: true)
    }
    
    func toImageSearch() {
        let vc = ImageSearchViewController()
        let router = ImageSearchRouter(navigationController: navigationController)
        let viewModel = ImageSearchViewModel(router: router)
        vc.viewModel = viewModel
        if createPromptViewModel != nil {
            viewModel.outputs.selectedImage
                .drive(createPromptViewModel!.selectedImage)
                .disposed(by: viewModel.disposeBag)
        }
        navigationController.pushViewController(vc, animated: true)
    }

    func toPrompts() {
        navigationController.dismiss(animated: true)
    }
    
}

