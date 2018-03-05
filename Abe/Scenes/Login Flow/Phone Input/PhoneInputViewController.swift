
import Foundation
import AccountKit
import RxSwift
import RxCocoa

protocol ChildViewControllerManager: class {
    func addChildViewController(_ viewController: UIViewController, frame: CGRect?, animated: Bool)
    func removeChildViewController(_ viewController: UIViewController, completion: (() -> Void)?)
}

extension ChildViewControllerManager where Self: UIViewController {
    
    func addChildViewController(_ viewController: UIViewController, frame: CGRect?, animated: Bool) {
        self.addChildViewController(viewController)
        self.view.addSubview(viewController.view)
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewController.didMove(toParentViewController: self)
        if let frame = frame { viewController.view.frame = frame }
        
        guard animated else { view.alpha = 1.0; return }
        UIView.transition(with: view, duration: 0.5, options: .curveEaseIn, animations: {
            self.view.alpha = 1.0
        }) { _ in }
    }
    
    func removeChildViewController(_ viewController: UIViewController, completion: (() -> Void)?) {
        viewController.willMove(toParentViewController: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParentViewController()
        if completion != nil { completion!() }
    }
    
}

class PhoneInputViewController: UIViewController, ChildViewControllerManager {
    
    private var accountKit = AKFAccountKit(responseType: .accessToken)
    //private var dataEntryViewController: AKFViewController? = nil

    let disposeBag = DisposeBag()
    var router: PhoneEntryRoutingLogic!
    private var isLogin: Bool
    
    init(isLogin: Bool) {
        self.isLogin = isLogin
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let viewController = accountKit.viewControllerForPhoneLogin()
        prepareDataEntryViewController(viewController)
        self.addChildViewController(viewController, frame: view.frame, animated: false)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func showError(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
}

extension PhoneInputViewController: AKFViewControllerDelegate {
    
    func prepareDataEntryViewController(_ viewController: AKFViewController) {
        viewController.delegate = self
    }
    
    func viewController(_ viewController: (UIViewController & AKFViewController)!, didCompleteLoginWith accessToken: AKFAccessToken!, state: String!) {
        print("LOGIN SUCCESS \(accessToken.tokenString)")
        router.toCreateUserWith(accessToken: accessToken.tokenString, isLogin: isLogin)
    }
    
    func viewController(_ viewController: (UIViewController & AKFViewController)!, didFailWithError error: Error!) {
        print("\(viewController) did fail with error: \(error)")
    }

}

