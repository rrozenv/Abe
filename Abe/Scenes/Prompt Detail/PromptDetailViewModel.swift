
import Foundation
import RxSwift
import RxCocoa
import RealmSwift
import RxRealm

struct CellViewModel {
    let reply: Observable<PromptReply>
    let scoreCellViewModels: Observable<[ScoreCellViewModel]>
    let userDidReply: Observable<Bool>
    let userScore: Observable<ReplyScore?>
}

typealias ReplyChangeSet = (AnyRealmCollection<PromptReply>, RealmChangeset?)

struct PromptDetailViewModel {
    
    struct Input {
        let createReplyTrigger: Driver<Void>
        let backTrigger: Driver<Void>
    }
    
    struct Output {
        let replies: Driver<[CellViewModel]>
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
        guard let defaultsUser = UserDefaultsManager.userInfo() else { fatalError() }
        
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
        
        let replyViewModels = _allReplies
            .map { (replies) -> [CellViewModel] in
                return replies.map { (reply) in
                    let userScore =
                        self.fetchCurrentUserScoreIfExists(for: reply,
                                                           currentUserId: defaultsUser.id)
                    let userDidReply = userScore != nil ? true : false
                    let scoreCellViewModels = [#imageLiteral(resourceName: "IC_Score_One_Unselected"), #imageLiteral(resourceName: "IC_Score_Two_Unselected"), #imageLiteral(resourceName: "IC_Score_Three_Unselected"), #imageLiteral(resourceName: "IC_Score_Four_Unselected"), #imageLiteral(resourceName: "IC_Score_Five_Unselected")].map {
                        return ScoreCellViewModel(userDidReply: userDidReply,
                                                  placeholderImage: $0,
                                                  userScore: userScore)
                    }
                    return CellViewModel(reply: Observable.of(reply),
                                         scoreCellViewModels: Observable.of(scoreCellViewModels),
                                         userDidReply: Observable.of(userDidReply),
                                         userScore: Observable.of(userScore))
                }
            }
        
        //2. Merged list
//        let finalizedReplyList = Observable
//            .of(_allReplies, _filteredContactReplies)
//            .merge()
//            .asDriverOnErrorJustComplete()

        let createReply = input
            .createReplyTrigger
            .do(onNext: { self.router.toCreateReply(for: self.prompt) })
        
        let dismiss = input.backTrigger.do(onNext: router.toPrompts)
        
        return Output(replies: replyViewModels,
                      createReply: createReply,
                      dismissViewController: dismiss,
                      fetching: fetching,
                      errors: errors)
    }
    
    func fetchCurrentUserScoreIfExists(for reply: PromptReply, currentUserId: String) -> ReplyScore? {
        let score = reply.scores.filter(NSPredicate(format: "userId = %@", currentUserId)).first
        return score ?? nil
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
