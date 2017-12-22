
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
        
        let _user = self.commonRealm
            .fetch(User.self, primaryKey: SyncUser.current!.identity!)
            .unwrap()
        
        //1. Make sure replies
        let _userContactNumers = self.privateRealm
            .fetchAllResults(Contact.self)
            .map { $0.flatMap { $0.numbers } }

        let _contactsReplies = self.commonRealm
            .fetchResults(PromptReply.self, with: predicate)
            .map { $0.filter { $0.visibility == "contacts" } }

//        let _filteredContactReplies = Observable
//            .combineLatest(_user, _contactsReplies, _userContactNumers) { (user, replies, userNumbers) -> [PromptReply] in
//            return replies.filter {
//                guard let replyUserPhone = $0.user?.phoneNumber else { return false }
//                return userNumbers.contains(replyUserPhone)
//            }
//        }
//        .startWith([])
//        .asDriverOnErrorJustComplete()
//
        //2. Replies marked all
        let _allReplies = self.commonRealm
            .fetchResults(PromptReply.self, with: predicate)
            .map { $0.filter { $0.visibility == "all" } }
            .asDriverOnErrorJustComplete()
        
        //2. Merged list
//        let finalizedReplyList = Observable
//            .of(_allReplies, _filteredContactReplies)
//            .merge()
//            .asDriverOnErrorJustComplete()

        let createReply = input
            .createReplyTrigger
            .do(onNext: { self.router.toCreateReply(for: self.prompt) })
        
        let dismiss = input.backTrigger.do(onNext: router.toPrompts)
        
        return Output(replies: _allReplies,
                      createReply: createReply,
                      dismissViewController: dismiss,
                      fetching: fetching,
                      errors: errors)
    }
    
    
    //                outerLoop: for reply in replies {
    //                    if reply.visibility == "contacts" {
    //                        for contact in contacts {
    //                            if contact.numbers.contains(user.phoneNumber) {
    //                                repliesToDisplay.append(reply)
    //                                continue outerLoop
    //                            }
    //                        }
    //                    }
    //                }

    
}
