
import Foundation
import RxSwift
import RxCocoa
import RealmSwift
import RxRealm

typealias ReplyChangeSet = (AnyRealmCollection<PromptReply>, RealmChangeset?)

struct PromptDetailViewModel {
    
    struct Input {
        let createReplyTrigger: Driver<Void>
        let backTrigger: Driver<Void>
    }
    
    struct Output {
        let replies: Driver<[PromptReply]>
        let createReply: Driver<Void>
        let dismissViewController: Driver<Void>
        let fetching: Driver<Bool>
        let errors: Driver<Error>
    }
    
    private let prompt: Prompt
    private let router: PromptDetailRoutingLogic
    private let commonRealm: RealmInstance
    private let privateRealm: RealmInstance
    
    init(commonRealm: RealmInstance,
         privateRealm: RealmInstance,
         prompt: Prompt,
         router: PromptDetailRoutingLogic) {
        self.prompt = prompt
        self.router = router
        self.commonRealm = commonRealm
        self.privateRealm = privateRealm
    }
    
    func transform(input: Input) -> Output {
        let activityIndicator = ActivityIndicator()
        let errorTracker = ErrorTracker()
        let fetching = activityIndicator.asDriver()
        let errors = errorTracker.asDriver()
        
        let predicate = NSPredicate(format: "promptId = %@", prompt.id)
        
        let user = self.commonRealm
            .fetch(User.self, primaryKey: SyncUser.current!.identity!)
            .unwrap()
        
        let userContacts = self.privateRealm
            .fetchAllResults(Contact.self)
        
        let replies = self.commonRealm
            .fetchResults(PromptReply.self, with: predicate)
        
        let filteredReplies = Observable
            .combineLatest(user, userContacts, replies) { (user, contacts, replies) -> [PromptReply] in
            var repliesToDisplay = [PromptReply]()
                outerLoop: for reply in replies {
                    if reply.visibility == "contacts" {
                        for contact in contacts {
                            if contact.numbers.contains(user.phoneNumber) {
                                repliesToDisplay.append(reply)
                                continue outerLoop
                            }
                        }
                    }
                }
            return repliesToDisplay
        }
        .asDriverOnErrorJustComplete()
        
        let createReply = input
            .createReplyTrigger
            .do(onNext: { self.router.toCreateReply(for: self.prompt) })
        
        let dismiss = input.backTrigger.do(onNext: router.toPrompts)
        
        return Output(replies: filteredReplies,
                      createReply: createReply,
                      dismissViewController: dismiss,
                      fetching: fetching,
                      errors: errors)
    }

    
}
