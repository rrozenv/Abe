
import UIKit
import RealmSwift
import RxSwift

final class AppController: UIViewController {
    
    //MARK: - Properties
    private let disposeBag = DisposeBag()
    static let shared = AppController(userService: UserService())
    var currentUser = Variable<User?>(nil)
    
    private let userService: UserService
    private var actingVC: UIViewController!
    
    private init(userService: UserService) {
        self.userService = userService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addNotificationObservers()
        loadInitialViewController()
    }
    
}

// MARK: - Notficiation Observers
extension AppController {
    
    fileprivate func addNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(switchViewController(with:)), name: .closeLoginVC, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(switchViewController(with:)), name: .closeOnboardingVC, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(switchViewController(with:)), name: .logout, object: nil)
    }
    
}

// MARK: - Loading VC's
extension AppController {
    
    private func setUpdateUsersFriendsSubscription() {
        currentUser.asObservable().unwrap()
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .flatMap { [unowned self] _ in self.userService.fetchAll() }
            .map { [unowned self] in self.currentUser.value?.registeredUsersInContacts(allUsers: $0) }.unwrap()
            .flatMap { [unowned self] in self.userService.add(userFriends: $0, to: self.currentUser.value!) }
            .subscribe(onNext: { [unowned self] (results) in
                self.currentUser.value = results.1
            })
            .disposed(by: disposeBag)
    }
    
    fileprivate func loadInitialViewController() {
        if let currentUser = self.fetchCurrentUser() {
            self.currentUser.value = currentUser
            self.actingVC = createHomeViewController()
        } else {
            RealmAuth.resetDefaultRealm()
            self.actingVC = createEnableContactsViewController()
        }
        self.add(viewController: self.actingVC, animated: true)
    }
    
    private func createEnableContactsViewController() -> UIViewController {
        let navVc = UINavigationController()
        let router = EnableContactsRouter(navigationController: navVc)
        router.toRoot()
        return navVc
    }
    
    private func createHomeViewController() -> UINavigationController {
        let navVc = UINavigationController()
        let promptsVc = PromptsListViewController()
        let router = PromptsRouter(navigationController: navVc,
                                   viewController: promptsVc)
        let realm = RealmInstance(configuration: RealmConfig.common)
        promptsVc.viewModel = PromptsListViewModel(realm: realm, router: router)
        router.toPrompts()
        return navVc
    }
    
}

// MARK: - Fetch Current User
extension AppController {
    
    private func fetchCurrentUser() -> User? {
        guard let currentSyncUser = RealmAuth.fetchCurrentSyncUser() else {
            return nil
        }
        return self.userService.fetchUser(key: currentSyncUser.identity!)
    }
    
}

// MARK: - Displaying VC's
extension AppController {
    
    private func add(viewController: UIViewController, animated: Bool = false) {
        self.addChildViewController(viewController)
        view.addSubview(viewController.view)
        view.alpha = 0.0
        viewController.view.frame = view.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewController.didMove(toParentViewController: self)
        
        guard animated else { view.alpha = 1.0; return }
        
        UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.view.alpha = 1.0
        }) { _ in }
    }
    
    @objc func switchViewController(with notification: Notification) {
        switch notification.name {
        case Notification.Name.closeLoginVC:
            let homeVc = self.createHomeViewController()
            switchToViewController(homeVc)
        case Notification.Name.closeOnboardingVC: break
        case Notification.Name.logout: break
        default:
            fatalError("\(#function) - Unable to match notficiation name.")
        }
    }
    
    private func switchToViewController(_ viewController: UIViewController) {
        let existingVC = actingVC
        existingVC?.willMove(toParentViewController: nil)
        add(viewController: viewController)
        actingVC.view.alpha = 0.0
        
        UIView.animate(withDuration: 0.8, animations: {
            self.actingVC.view.alpha = 1.0
            existingVC?.view.alpha = 0.0
        }) { success in
            existingVC?.view.removeFromSuperview()
            existingVC?.removeFromParentViewController()
            self.actingVC.didMove(toParentViewController: self)
        }
    }
    
}

// MARK: - Notification Extension
extension Notification.Name {
    static let closeOnboardingVC = Notification.Name("close-onboarding-view-controller")
    static let closeLoginVC = Notification.Name("close-login-view-controller")
    static let logout = Notification.Name("logout")
    static let locationChanged = Notification.Name("locationChanged")
}

