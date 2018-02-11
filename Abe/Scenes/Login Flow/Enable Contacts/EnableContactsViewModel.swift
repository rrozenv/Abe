
import Foundation
import RxSwift
import RxCocoa

protocol AllowContactsViewModelInputs {
    var allowContactsTappedInput: AnyObserver<Void> { get }
}

protocol AllowContactsViewModelOuputs {
    var errorTracker: Driver<Error> { get }
}

protocol AllowContactsViewModelType {
    var inputs: AllowContactsViewModelInputs { get }
    var outputs: AllowContactsViewModelOuputs { get }
}

final class AllowContactsViewModel: AllowContactsViewModelInputs, AllowContactsViewModelOuputs, AllowContactsViewModelType {
    
    let disposeBag = DisposeBag()
    
    //MARK: - Inputs
    var inputs: AllowContactsViewModelInputs { return self }
    let allowContactsTappedInput: AnyObserver<Void>
    
    //MARK: - Outputs
    var outputs: AllowContactsViewModelOuputs { return self }
    let errorTracker: Driver<Error>
    
    //MARK: - Init
    init(contactService: ContactService = ContactService(),
         contactsStore: ContactsStore = ContactsStore(),
         router: EnableContactsRouter) {
        
        let errorTracker = ErrorTracker()
        self.errorTracker = errorTracker.asDriver()
        
        //MARK: - Subjects
        let _allowContactsTappedInput = PublishSubject<Void>()
        
        //MARK: - Observers
        self.allowContactsTappedInput = _allowContactsTappedInput.asObserver()
      
        //MARK: - Routing
        let authStatusObservable = _allowContactsTappedInput.asObservable()
            .flatMapLatest { _ in contactsStore.isAuthorized() }
            .asDriver(onErrorJustReturn: false)
        
        let requestContactsAccessObservable = authStatusObservable
            .filter { !$0 }
            .flatMapLatest { _ in
                return contactsStore.requestAccess()
                    .trackError(errorTracker)
                    .asDriver(onErrorJustReturn: false)
            }
            .asDriver(onErrorJustReturn: false)
        
        Driver.of(requestContactsAccessObservable, authStatusObservable)
            .merge()
            .filter { $0 }
            .mapToVoid()
            .do(onNext: router.toNameInput)
            .drive()
            .disposed(by: disposeBag)
    }
    
}



struct EnableContactsViewModel {
    
    struct Input {
        let allowContactsTapped: Driver<Void>
    }
    
    struct Output {
        let didSaveContacts: Driver<Void>
        let loading: Driver<Bool>
        let errors: Driver<Error>
    }
    
    private let contactService: ContactService
    private let contactsStore: ContactsStore
    private let router: EnableContactsRouter
    
    init(contactService: ContactService = ContactService(),
         contactsStore: ContactsStore = ContactsStore(),
         router: EnableContactsRouter) {
        self.contactService = contactService
        self.contactsStore = contactsStore
        self.router = router
    }
    
    func transform(input: Input) -> Output {
        let activityIndicator = ActivityIndicator()
        let errorTracker = ErrorTracker()
        let loading = activityIndicator.asDriver()
        let errors = errorTracker.asDriver()
        
        let _authStatus = input.allowContactsTapped
            .flatMapLatest { _ in
                return self.contactsStore
                    .isAuthorized()
                    .asDriverOnErrorJustComplete()
            }
        
        let _requestContactsAccess = _authStatus
            .filter { !$0 }
            .flatMapLatest { _ in
                return self.contactsStore
                    .requestAccess()
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
            }
        
        let didSaveContacts = Driver.of(_requestContactsAccess, _authStatus)
            .merge()
            .filter { $0 }
//            .flatMapLatest { _ in
//                self.contactsStore
//                    .userContacts()
//                    .trackError(errorTracker)
//                    .trackActivity(activityIndicator)
//                    .asDriverOnErrorJustComplete()
//            }
//            .flatMapLatest { (contacts) in
//                self.contactService
//                    .saveAll(contacts)
//                    .trackError(errorTracker)
//                    .trackActivity(activityIndicator)
//                    .asDriverOnErrorJustComplete()
//            }
            .mapToVoid()
            .do(onNext: router.toNameInput)
        
        return Output(didSaveContacts: didSaveContacts,
                      loading: loading,
                      errors: errors)
    }
        
}

