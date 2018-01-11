
import Foundation
import RxSwift
import RxCocoa


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
    
    init(contactService: ContactService,
         contactsStore: ContactsStore,
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

