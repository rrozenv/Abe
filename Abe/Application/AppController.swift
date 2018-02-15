
import UIKit
import RealmSwift
import RxSwift
import RxRealm
import AccountKit

enum AccountKitError: Error {
    case standardError
    case noAccountId
}

final class AccountKitServie {
    
    private var accountKit = AKFAccountKit(responseType: .accessToken)
    
     func requestUserAccountInfo(completion: @escaping (_ accountId: String?, _ error: Error?) -> Void) {
        accountKit.requestAccount { (account, error) in
            if let error = error {
                completion(nil, error)
            } else if let id = account?.accountID {
                completion(id, nil)
            } else {
                completion(nil, nil)
            }
        }
     }
    
    func fetchUserAccountIdObservable() -> Observable<(id: String, number: String)> {
        return Observable.create { [unowned self] observer in
            self.accountKit.requestAccount { (account, error) in
                if let _ = error {
                    observer.onError(AccountKitError.standardError)
                }
                if let id = account?.accountID,
                    let number = account?.phoneNumber?.phoneNumber {
                    observer.onNext((id, number))
                    observer.onCompleted()
                } else {
                    observer.onError(AccountKitError.noAccountId)
                }
            }
            return Disposables.create()
        }
    }
}

final class AppController: UIViewController {
  
    //MARK: - Properties
    private let disposeBag = DisposeBag()
    static let shared = AppController(userService: UserService())
    var currentUser = Variable<User?>(nil)
    //private var accountKit = AKFAccountKit(responseType: .accessToken)
    
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
        UIApplication.shared.isStatusBarHidden = true
        //setUpdateUsersFriendsSubscription()
        addNotificationObservers()
        loadInitialViewController()
        //loadInitalVCTest()
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
        
        currentUser.asObservable().unwrap().take(1)
            //.subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .flatMap { [unowned self] _ in self.userService.fetchAll() }
            .map { [unowned self] in self.currentUser.value?.registeredUsersInContacts(allUsers: $0) }.unwrap()
            .flatMap { [unowned self] in self.userService.add(userFriends: $0, to: self.currentUser.value!) }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] (results) in
                self.currentUser.value = results.1
            })
            .disposed(by: disposeBag)
    }
    
    private func loadInitialViewController() {

//        let user = self.fetchUserFor(uuid: "f3256ae7afe6eb8c90683ccd6a68121f")
//        if let user = user {
//            print("Found user: \(user.name)!")
//        } else {
//            print("user is nil now!")
//        }
//
//        self.userService.fetchAll()
//            .do(onNext: {
//                print("I found \($0.count) users")
//                let user = $0.filter { $0.id == "f3256ae7afe6eb8c90683ccd6a68121f" }.first
//                print("I found user \(String(describing: user?.name))")
//            })
//            .subscribe()
//            .disposed(by: disposeBag)

        if let currentUser = self.fetchCurrentUser() {
            self.currentUser.value = currentUser
            self.actingVC = createHomeViewController()

        } else {
            //Add defaults check to see if onborading needs to be shown
            RealmAuth.resetDefaultRealm()
            self.actingVC = createSignupLoginViewController()
        }
        self.add(viewController: self.actingVC, animated: true)
    }
    
//    private func loadInitalVCTest() {
//        guard accountKit.currentAccessToken == nil &&
//            RealmAuth.fetchCurrentSyncUser() == nil else {
//            self.requestUserAccountInfo { [unowned self] (id, error) in
//                if let id = id,
//                   let user = self.fetchUserFor(uuid: id),
//                   error == nil {
//                    self.currentUser.value = user
//                    self.actingVC = self.createHomeViewController()
//                } else {
//                    print(error?.localizedDescription ?? "No Error")
//                    print("User does not exist")
//                    RealmAuth.resetDefaultRealm()
//                    self.actingVC = self.createSignupLoginViewController()
//                }
//                self.add(viewController: self.actingVC, animated: true)
//            }
//            return
//        }
//        RealmAuth.resetDefaultRealm()
//        self.actingVC = self.createSignupLoginViewController()
//        self.add(viewController: self.actingVC, animated: true)
//    }
    
    private func createSignupLoginViewController() -> UIViewController {
        let navVc = UINavigationController()
        let router = SignupLoginRouter(navigationController: navVc)
        router.toRoot()
        return navVc
    }
    
    private func createHomeViewController() -> UINavigationController {
        let pageVc = PromptPageViewController()
        let navVc = UINavigationController(rootViewController: pageVc)
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
    
    private func fetchUserFor(uuid: String) -> User? {
        return self.userService.fetchUser(key: uuid)
    }
    
//    private func requestUserAccountInfo(completion: @escaping (_ accountId: String?, _ error: Error?) -> Void) {
//        accountKit.requestAccount { (account, error) in
//            if let error = error {
//                completion(nil, error)
//            } else if let id = account?.accountID {
//                completion(id, nil)
//            } else {
//                completion(nil, nil)
//            }
//        }
//    }
//
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

