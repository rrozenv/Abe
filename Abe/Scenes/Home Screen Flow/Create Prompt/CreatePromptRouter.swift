
import Foundation
import UIKit

protocol CreatePromptRoutingLogic {
    func toMainInput()
    func toPrompts()
    func toAddWebLink()
    func toImageSearch()
}

final class CreatePromptRouter: CreatePromptRoutingLogic {
    weak private var navigationController: UINavigationController?
    weak var createPromptViewModel: CreatePromptViewModel?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func toMainInput() {
        var vc = CreatePromptViewController()
        let promptService = PromptService()
        let viewModel = CreatePromptViewModel(promptService: promptService, router: self)
        vc.setViewModelBinding(model: viewModel!)
        self.createPromptViewModel = viewModel
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func toImageSearch() {
        let vc = ImageSearchViewController()
        let router = ImageSearchRouter(navigationController: navigationController!)
        let viewModel = ImageSearchViewModel(router: router)
        vc.viewModel = viewModel
        if createPromptViewModel != nil {
            viewModel.outputs.selectedImage
                .debug()
                .drive(createPromptViewModel!.selectedImage)
                .disposed(by: viewModel.disposeBag)
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func toAddWebLink() {
        var vc = AddWebLinkViewController()
        let router = AddWebLinkRouter(navigationController: navigationController!)
        let viewModel = AddWebLinkViewModel(router: router)
        vc.setViewModelBinding(model: viewModel)
        
//        if createPromptViewModel != nil {
//            viewModel.outputs.selectedImage
//                .debug()
//                .drive(createPromptViewModel!.selectedImage)
//                .disposed(by: viewModel.disposeBag)
//        }
        navigationController?.pushViewController(vc, animated: true)
    }

    func toPrompts() {
        navigationController?.dismiss(animated: true)
    }
    
}

