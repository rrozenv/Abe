
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
    
    private let realm: RealmRepresentable
    private let router: ReplyOptionsRoutingLogic
    private let prompt: Prompt
    private let contactsStore: ContactsStore
    private let savedReplyInput: SavedReplyInput
    
    init(realm: RealmRepresentable,
         prompt: Prompt,
         savedReplyInput: SavedReplyInput,
         router: ReplyOptionsRoutingLogic) {
        self.prompt = prompt
        self.realm = realm
        self.contactsStore = ContactsStore()
        self.savedReplyInput = savedReplyInput
        self.router = router
    }
    
    func transform(input: Input) -> Output {
        
        let activityIndicator = ActivityIndicator()
        let errorTracker = ErrorTracker()
        let loading = activityIndicator.asDriver()
        let errors = errorTracker.asDriver()
        
        //MARK: - 1. let visibilityOptions: Driver<[Visibility]>
        let _options: [Visibility] = [.all, .facebook, .contacts]
        let visbilityOptions = Driver.of(_options)
        
        let _user = self.realm
            .fetch(User.self, primaryKey: SyncUser.current!.identity!)
            .unwrap()
            .asDriverOnErrorJustComplete()
        
        //MARK: - 2. let savedContacts: Driver<Void>
        let _selectedVisibility = input.visibilitySelected
        
        let _shouldAskForContacts = _selectedVisibility
            .filter { $0 == Visibility.contacts }
            .withLatestFrom(_user)
            .map { $0.contacts.count }
            .filter { $0 < 1 }
        
        let _userContacts = _shouldAskForContacts
            .mapToVoid()
            .flatMapLatest { _ in
                return self.contactsStore.isAuthorized()
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
            }
            .map{ $0 }
            .flatMap { _ in
                self.contactsStore.userContacts().asDriverOnErrorJustComplete()
            }
    
        let savedContacts = _userContacts
            .withLatestFrom(_user) { (contacts, user) in
                return self.realm.update {
                    contacts.forEach { user.contacts.append($0) }
                }
                .trackError(errorTracker)
                .trackActivity(activityIndicator)
            }
            .mapToVoid()
        
        //3. MARK: - let didCreateReply: Observable<Void>
        let _currentPrompt = Driver.of(prompt)
        let _savedReplyInput = Driver.of(self.savedReplyInput)
        
        let _reply =
            Driver.combineLatest(_currentPrompt,
                                 _user,
                                 _savedReplyInput,
                                 _selectedVisibility) { (prompt, user, replyInput, visibility) -> PromptReply in
            return PromptReply(userId: user.id,
                               userName: user.name,
                               promptId: prompt.id,
                               body: replyInput.body,
                               visibility: visibility.rawValue)
        }
        
        let didCreateReply = input.createTrigger
            .asObservable()
            .withLatestFrom(_reply)
            .flatMapLatest { (reply) -> Observable<Void> in
                return self.realm.update {
                        self.prompt.replies.insert(reply, at: 0)
                    }
                    .trackActivity(activityIndicator)
                    .trackError(errorTracker)
            }
            .do(onNext: router.toPromptDetail)
        
        return Output(visibilityOptions: visbilityOptions,
                      didCreateReply: didCreateReply,
                      savedContacts: savedContacts,
                      loading: loading,
                      errors: errors)
    }

}
