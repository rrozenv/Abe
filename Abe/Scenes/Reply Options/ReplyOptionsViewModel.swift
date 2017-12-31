
import Foundation
import RxSwift
import RxCocoa
import Action
import RealmSwift
import Contacts

enum Visibility: String {
    case all
    case facebook
    case contacts
}

struct SavedReplyInput {
    let body: String
    let prompt: Prompt
}

struct ReplyOptionsViewModel {
    
    struct Input {
        let createTrigger: Driver<Void>
        let visibilitySelected: Driver<Visibility>
        let cancelTrigger: Driver<Void>
    }
    
    struct Output {
        let visibilityOptions: Driver<[Visibility]>
        let didCreateReply: Observable<Void>
        let savedContacts: Driver<Void>
        let loading: Driver<Bool>
        let errors: Driver<Error>
    }
    
    var promptTitle: String { return prompt.title }
    
    private let commonRealm: RealmInstance
    private let privateRealm: RealmInstance
    private let router: ReplyOptionsRoutingLogic
    private let prompt: Prompt
    private let contactsStore: ContactsStore
    private let savedReplyInput: SavedReplyInput
    private let replyService: ReplyService
    
    init(commonRealm: RealmInstance,
         privateRealm: RealmInstance,
         replyService: ReplyService,
         prompt: Prompt,
         savedReplyInput: SavedReplyInput,
         router: ReplyOptionsRoutingLogic) {
        self.prompt = prompt
        self.commonRealm = commonRealm
        self.privateRealm = privateRealm
        self.contactsStore = ContactsStore()
        self.savedReplyInput = savedReplyInput
        self.router = router
        self.replyService = replyService
    }
    
    func transform(input: Input) -> Output {
        
        let activityIndicator = ActivityIndicator()
        let errorTracker = ErrorTracker()
        let loading = activityIndicator.asDriver()
        let errors = errorTracker.asDriver()
        
        //MARK: - 1. let visibilityOptions: Driver<[Visibility]>
        let _options: [Visibility] = [.all, .facebook, .contacts]
        let visbilityOptions = Driver.of(_options)
        
        let _user = self.commonRealm
            .fetch(User.self, primaryKey: SyncUser.current!.identity!)
            .unwrap()
            .asDriverOnErrorJustComplete()
        
        //MARK: - 2. let savedContacts: Driver<Void>
        let _selectedVisibility = input.visibilitySelected
        
        let _contactsAuthStatus = _selectedVisibility
            .filter { $0 == Visibility.contacts }
            .flatMapLatest { _ in
                return self.contactsStore.isAuthorized()
                    .asDriverOnErrorJustComplete()
            }
        
        let _requestContactsAccess = _contactsAuthStatus
            .map{ !$0 }
            .flatMapLatest { _ in
                return self.contactsStore.requestAccess()
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
            }
        
        let saveContacts = Driver.of(_requestContactsAccess, _contactsAuthStatus)
            .merge()
            .map{ $0 }
            .flatMapLatest { _ in
                self.contactsStore.userContacts().asDriverOnErrorJustComplete()
            }
            .flatMapLatest { (contacts) in
                self.privateRealm.save(objects: contacts)
                .asDriverOnErrorJustComplete()
            }
    
        //3. MARK: - let didCreateReply: Observable<Void>
        let _currentPrompt = Driver.of(prompt)
        let _savedReplyInput = Driver.of(self.savedReplyInput)
        
        let _reply =
            Driver.combineLatest(_currentPrompt,
                                 _user,
                                 _savedReplyInput,
                                 _selectedVisibility) { (prompt, user, replyInput, visibility) -> PromptReply in
                                    return PromptReply(user: user,
                                                       promptId: prompt.id,
                                                       body: replyInput.body,
                                                       visibility: visibility.rawValue)
        }
        
        let didCreateReply = input.createTrigger
            .asObservable()
            .withLatestFrom(_reply)
            .flatMapLatest { (reply) in
                return self.replyService.saveReply(reply)
            }
            .flatMapLatest { (reply) in
                return self.replyService.add(reply: reply, to: self.prompt)
            }
            .mapToVoid()
            .do(onNext: router.toPromptDetail)
        
        return Output(visibilityOptions: visbilityOptions,
                      didCreateReply: didCreateReply,
                      savedContacts: saveContacts,
                      loading: loading,
                      errors: errors)
    }

}
