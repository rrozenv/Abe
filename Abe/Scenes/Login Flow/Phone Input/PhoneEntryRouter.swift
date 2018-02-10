
import Foundation
import UIKit

protocol PhoneEntryRoutingLogic {
    func toHome()
    func toCreateUserWith(accessToken: String, isLogin: Bool)
}

final class PhoneEntryRouter: PhoneEntryRoutingLogic {
    
    private weak var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func toHome() {
        NotificationCenter.default.post(name: .closeLoginVC, object: nil)
    }
    
    func toCreateUserWith(accessToken: String, isLogin: Bool) {
        var vc = CreateUserViewController()
        let router = CreateUserRouter()
        let viewModel = CreateUserViewModel(accessToken: accessToken,
                                            isLogin: isLogin,
                                            router: router)
        vc.setViewModelBinding(model: viewModel)
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

