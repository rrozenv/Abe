
import Foundation
import RxSwift
import RxCocoa
import RealmSwift
import RxRealm

struct CellViewModel {
    let reply: PromptReply
    let scoreCellViewModels: [ScoreCellViewModel]
    let userDidReply: Bool
    let userScore: ReplyScore?
}

typealias ReplyChangeSet = (AnyRealmCollection<PromptReply>, RealmChangeset?)

struct PromptDetailViewModel {
    
    // MARK: - Properties
    
    let disposeBag = DisposeBag()
    var replies: Driver<[CellViewModel]> { return _replies.asDriver() }
    
    // MARK: -

    private let _replies = Variable<[CellViewModel]>([])

    struct Input {
        let refreshTrigger: Driver<Void>
        let currentlySelectedTab: Driver<Visibility>
        let createReplyTrigger: Driver<Void>
        let backTrigger: Driver<Void>
        let scoreSelected: PublishSubject<(CellViewModel, ScoreCellViewModel)>
    }
    
    struct Output {
        let replies: Driver<[CellViewModel]>
        let createReply: Driver<Void>
        let saveScore: Observable<CellViewModel>
        let dismissViewController: Driver<Void>
        let fetching: Driver<Bool>
        let errors: Driver<Error>
        let didBindReplies: Disposable
    }
    
    private let prompt: Prompt
    private let router: PromptDetailRoutingLogic
    private let commonRealm: RealmInstance
    private let privateRealm: RealmInstance
    private let user: UserInfo
    
    init(commonRealm: RealmInstance,
         privateRealm: RealmInstance,
         prompt: Prompt,
         router: PromptDetailRoutingLogic) {
        self.prompt = prompt
        self.router = router
        self.commonRealm = commonRealm
        self.privateRealm = privateRealm
        self.user = UserDefaultsManager.userInfo()!
    }
    
    func transform(input: Input) -> Output {
        let activityIndicator = ActivityIndicator()
        let errorTracker = ErrorTracker()
        let fetching = activityIndicator.asDriver()
        let errors = errorTracker.asDriver()
    
        let predicate = NSPredicate(format: "promptId = %@", prompt.id)

        //MARK: - All Replies View Models
        let _allReplies = input.currentlySelectedTab
            .filter { $0 == Visibility.all }
            .flatMapLatest { (allVis) in
                return self.commonRealm
                    .fetchResults(PromptReply.self, with: predicate)
                    .map { $0.filter { $0.visibility == allVis.rawValue } }
                    .trackActivity(activityIndicator)
                    .trackError(errorTracker)
                    .asDriver(onErrorJustReturn: [PromptReply]())
            }
            .map { self.createReplyCellViewModels(with: $0) }

        //MARK: - Contact Replies View Models
        let _contactReplies = input.currentlySelectedTab
            .debug()
            .filter { $0 == Visibility.contacts }
            .flatMapLatest { (contactsVis) in
                return self.commonRealm
                    .fetchResults(PromptReply.self, with: predicate)
                    .map { $0.filter { $0.visibility == contactsVis.rawValue } }
                    .trackActivity(activityIndicator)
                    .trackError(errorTracker)
                    .asDriver(onErrorJustReturn: [PromptReply]())
            }
        
        let _userContactNumers = self.privateRealm
            .fetchAllResults(Contact.self)
            .map { $0.flatMap { $0.numbers } }
            .startWith([String]())
            .asDriver(onErrorJustReturn: [String]())
    
        let _filteredContactReplies = Driver
            .combineLatest(_contactReplies, _userContactNumers) { (replies, userNumbers) -> [PromptReply] in
                return replies.filter { (reply) -> Bool in
                    guard let replyUserPhone = reply.user?.phoneNumber else { return false }
                    return userNumbers.contains(replyUserPhone)
                }
            }
            .map { self.createReplyCellViewModels(with: $0) }

        //MARK: - Bind Replies
        //All replies must come LAST because they are shown FIRST
        let didBindReplies = Observable.of(_filteredContactReplies, _allReplies)
            .debug()
            .merge()
            .bind(to: self._replies)
        
        let saveScore = input
            .scoreSelected
            .asObservable()
            .filter { !$0.0.userDidReply }
            .flatMap { (vm) -> Observable<CellViewModel> in
                let replyScore = ReplyScore(userId: self.user.id,
                                            replyId: vm.0.reply.id,
                                            score: vm.1.value)
                
                self.commonRealm.updateWrite {
                    vm.0.reply.scores.append(replyScore)
                }
                
                return .just(CellViewModel(reply: vm.0.reply,
                                     scoreCellViewModels: vm.0.scoreCellViewModels,
                                     userDidReply: true,
                                     userScore: replyScore))
            }
            .do(onNext: { (cellVm) in
                let index = self._replies.value.index(where: { $0.reply.id == cellVm.reply.id })
                self._replies.value[index!] = cellVm
            })

        let createReply = input
            .createReplyTrigger
            .do(onNext: { self.router.toCreateReply(for: self.prompt) })
        
        let dismiss = input.backTrigger.do(onNext: router.toPrompts)
        
        return Output(replies: _replies.asDriver(),
                      createReply: createReply,
                      saveScore: saveScore,
                      dismissViewController: dismiss,
                      fetching: fetching,
                      errors: errors,
                      didBindReplies: didBindReplies)
    }
    
    //MARK: - Helper Methods
    
    private func createReplyCellViewModels(with replies: [PromptReply]) -> [CellViewModel] {
        return replies.map { (reply) in
            let userScore = self.fetchCurrentUserScoreIfExists(for: reply, currentUserId: user.id)
            let userDidReply = (userScore != nil) ? true : false
            let scoreCellViewModels =
                createScoreCellViewModels(for: reply,
                                          userDidReply: userDidReply,
                                          userScore: userScore)
            return CellViewModel(reply: reply,
                                 scoreCellViewModels: scoreCellViewModels,
                                 userDidReply: userDidReply,
                                 userScore: userScore)
        }
    }
    
    private func createCellViewModel(with reply: PromptReply) -> CellViewModel {
        let userScore = self.fetchCurrentUserScoreIfExists(for: reply, currentUserId: user.id)
        let userDidReply = (userScore != nil) ? true : false
        let scoreCellViewModels =
            createScoreCellViewModels(for: reply,
                                      userDidReply: userDidReply,
                                      userScore: userScore)
        return CellViewModel(reply: reply,
                             scoreCellViewModels: scoreCellViewModels,
                             userDidReply: userDidReply,
                             userScore: userScore)
    }
    
    private func createScoreCellViewModels(for reply: PromptReply,
                                   userDidReply: Bool,
                                   userScore: ReplyScore?) -> [ScoreCellViewModel] {
        return [#imageLiteral(resourceName: "IC_Score_One_Unselected"), #imageLiteral(resourceName: "IC_Score_Two_Unselected"), #imageLiteral(resourceName: "IC_Score_Three_Unselected"), #imageLiteral(resourceName: "IC_Score_Four_Unselected"), #imageLiteral(resourceName: "IC_Score_Five_Unselected")].enumerated().map {
                return ScoreCellViewModel(value: $0.offset + 1,
                                          reply: reply,
                                          userDidReply: userDidReply,
                                          placeholderImage: $0.element,
                                          userScore: userScore)
        }
    }
    
    private func fetchCurrentUserScoreIfExists(for reply: PromptReply,
                                               currentUserId: String) -> ReplyScore? {
        let score = reply.scores
            .filter(NSPredicate(format: "userId = %@", currentUserId)).first
        return score ?? nil
    }

    
}


//let repliesForPrompt = input.refreshTrigger
//    .flatMapLatest { _ in
//        return self.commonRealm
//            .fetchResults(PromptReply.self, with: predicate)
//            .trackActivity(activityIndicator)
//            .trackError(errorTracker)
//            .asDriver(onErrorJustReturn: [PromptReply]())
//}

//            .withLatestFrom(repliesForPrompt) { (contactsVis, replies) -> [PromptReply] in
//                return replies.filter { $0.visibility == contactsVis.rawValue }
//            }
//            .startWith([PromptReply]())

//            .withLatestFrom(repliesForPrompt) { (allVis, replies) -> [PromptReply] in
//                print("I have \(replies.count) at this point")
//                return replies.filter { $0.visibility == allVis.rawValue }
//            }
//            .map { self.createReplyCellViewModels(with: $0) }
