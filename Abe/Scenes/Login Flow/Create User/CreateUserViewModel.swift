
import Foundation
import RxSwift
import RxCocoa
import RealmSwift

protocol CreateUserViewModelInputs {
    var viewWillAppearInput: AnyObserver<Void> { get }
}

protocol CreateUserViewModelOutputs {
    var activityIndicator: Driver<Bool> { get }
    var errorTracker: Driver<Error> { get }
}

protocol CreateUserViewModelType {
    var inputs: CreateUserViewModelInputs { get }
    var outputs: CreateUserViewModelOutputs { get }
}

final class CreateUserViewModel: CreateUserViewModelType, CreateUserViewModelInputs, CreateUserViewModelOutputs {
    let disposeBag = DisposeBag()
    
//MARK: - Inputs
    var inputs: CreateUserViewModelInputs { return self }
    let viewWillAppearInput: AnyObserver<Void>
    
//MARK: - Outputs
    var outputs: CreateUserViewModelOutputs { return self }
    let activityIndicator: Driver<Bool>
    let errorTracker: Driver<Error>
    
//MARK: - Init
    init(accessToken: String,
         isLogin: Bool,
         userService: UserService = UserService(),
         contactStore: ContactsStore = ContactsStore(),
         contactService: ContactService = ContactService(),
         accountKitService: AccountKitServie = AccountKitServie(),
         router: CreateUserRoutingLogic) {
        
        let activityIndicator = ActivityIndicator()
        let errorTracker = ErrorTracker()
        self.activityIndicator = activityIndicator.asDriver()
        self.errorTracker = errorTracker.asDriver()
        
//MARK: - Subjects
        let _viewWillAppearInput = PublishSubject<Void>()
        
//MARK: - Observers
        self.viewWillAppearInput = _viewWillAppearInput.asObserver()
        
//MARK: - First Level Observables
        let viewWillAppearObservable = _viewWillAppearInput.asObservable()
        
        let accountIdAndPhoneNumberObservable = viewWillAppearObservable
            .debug()
            .flatMapLatest {
                accountKitService.fetchUserAccountIdObservable()
                    .trackActivity(activityIndicator)
                    .trackError(errorTracker)
            }
            .share()
        
//MARK: - Second Level Observables
        let realmSyncUserObservable = accountIdAndPhoneNumberObservable
            .flatMap { inputs -> Observable<Event<SyncUser>> in
                RealmAuth.authorize(email: inputs.number,
                                    password: inputs.number,
                                    register: isLogin ? false : true)
                    .trackActivity(activityIndicator)
                    .trackError(errorTracker)
                    .materialize()
            }
            .share()
        
//MARK: - Third Level Observables
        let currentUser = realmSyncUserObservable.elements()
            .debug()
            .filter { _ in isLogin }
            .flatMapLatest { _ in
                return userService.fetchUserFor(key: SyncUser.current!.identity!)
                    .trackError(errorTracker)
                    .trackActivity(activityIndicator)
            }
            .do(onNext: {
                if $0 != nil { print("Found user \($0!.name)") }
                else { print("user is nil!") }
            })
            .unwrap()
        
        let newUser = realmSyncUserObservable.elements()
            .filter { _ in !isLogin }
            .withLatestFrom(accountIdAndPhoneNumberObservable,
                            resultSelector: { (syncUser: $0, number: $1.number) })
            .flatMapLatest {
                userService.createUser(syncUser: $0.syncUser,
                                       name: UserDefaultsManager.userName()?.first ?? "",
                                       email: $0.number,
                                       phoneNumber: $0.number)
                    .trackActivity(activityIndicator)
                    .trackError(errorTracker)
            }
            .share()
        
//MARK: - Fourth Level Observables
        let userContacts = newUser
            .flatMapLatest { _ in
                contactStore
                    .userContacts()
                    .trackError(errorTracker)
                    .trackActivity(activityIndicator)
                    .asDriverOnErrorJustComplete()
        }
       
//MARK: - Routing
        currentUser
            .do(onNext: { AppController.shared.currentUser.value = $0 })
            .mapToVoid()
            .do(onNext: router.toHome)
            .observeOn(MainScheduler.instance)
            .subscribe()
            .disposed(by: disposeBag)
        
        userContacts
            .withLatestFrom(newUser, resultSelector: { (contacts, user) in
                return contactService.add(contacts: contacts, to: user)
            })
            .flatMap { $0 }
            .do(onNext: { AppController.shared.currentUser.value = $0 })
            .mapToVoid()
            .do(onNext: router.toHome)
            .observeOn(MainScheduler.instance)
            .subscribe()
            .disposed(by: disposeBag)
    }
}
