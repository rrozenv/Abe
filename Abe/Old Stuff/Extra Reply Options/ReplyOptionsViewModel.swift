
import Foundation
import RxSwift
import RxCocoa
import Action
import RealmSwift
import Contacts

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
    
    private let router: ReplyOptionsRoutingLogic
    private let prompt: Prompt
    private let contactsStore: ContactsStore
    private let savedReplyInput: SavedReplyInput
    private let replyService: ReplyService
    private let user: User
    private let privateRealm: RealmInstance
    
    init(replyService: ReplyService,
         privateRealm: RealmInstance,
         prompt: Prompt,
         savedReplyInput: SavedReplyInput,
         router: ReplyOptionsRoutingLogic) {
        guard let user = AppController.shared.currentUser.value else { fatalError() }
        self.user = user
        self.privateRealm = privateRealm
        self.prompt = prompt
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
        let _options: [Visibility] = [.all, .individualContacts, .contacts]
        let visbilityOptions = Driver.of(_options)
        
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
                                 _savedReplyInput,
                                 _selectedVisibility) { (prompt, replyInput, visibility) -> PromptReply in
                                    return PromptReply(user: self.user,
                                                       promptId: replyInput.prompt.id,
                                                       body: replyInput.reply!.body,
                                                       visibility:
                                                       visibility.rawValue)
        }
        
        let didCreateReply = input.createTrigger
            .asObservable()
            .withLatestFrom(_reply)
            .flatMapLatest { (reply) in
                return self.replyService.saveReply(reply)
                    .flatMapLatest { self.replyService.add(reply: $0, to: self.prompt) }
                    .flatMapLatest { self.replyService.add(reply: $0.0, to: self.user) }
            }
            .do(onNext: { _ in
                NotificationCenter.default.post(.init(name: .userUpdated, object: nil))
            })
            .mapToVoid()
            .do(onNext: router.toDismissNavVc)
        
        return Output(visibilityOptions: visbilityOptions,
                      didCreateReply: didCreateReply,
                      savedContacts: saveContacts,
                      loading: loading,
                      errors: errors)
    }

}
