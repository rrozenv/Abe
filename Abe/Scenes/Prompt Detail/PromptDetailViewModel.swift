
import Foundation
import RxSwift
import RxCocoa
import RealmSwift
import RxRealm

struct CellViewModel {
    let reply: PromptReply
    let index: Int
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
    private let replyService: ReplyService
    
    init(commonRealm: RealmInstance,
         privateRealm: RealmInstance,
         replyService: ReplyService,
         prompt: Prompt,
         router: PromptDetailRoutingLogic) {
        self.prompt = prompt
        self.router = router
        self.commonRealm = commonRealm
        self.privateRealm = privateRealm
        self.replyService = replyService
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
                return self.replyService
                    .fetchRepliesWith(predicate: predicate)
                    .map { $0.filter { $0.visibility == allVis.rawValue } }
                    .trackActivity(activityIndicator)
                    .trackError(errorTracker)
                    .asDriver(onErrorJustReturn: [PromptReply]())
            }
            .map { self.createReplyCellViewModels(with: $0) }

        //MARK: - Contact Replies View Models
        let _contactReplies = input.currentlySelectedTab
            .filter { $0 == Visibility.contacts }
            .flatMapLatest { (contactsVis) in
                return self.replyService
                    .fetchRepliesWith(predicate: predicate)
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
            .merge()
            .bind(to: self._replies)
        
        //MARK: - Save Score
        let _shouldSaveScore = input.scoreSelected.asObservable()
            .filter { (replyCellViewModel, _)  in !replyCellViewModel.userDidReply }
        
        let _replyWithNewScore = _shouldSaveScore
            .flatMapLatest { (viewModels) -> Observable<(PromptReply, ReplyScore)> in
                let replyCellViewModel = viewModels.0
                let scoreCellViewModel = viewModels.1
                let replyScore = ReplyScore(userId: self.user.id,
                                            replyId: replyCellViewModel.reply.id,
                                            score: scoreCellViewModel.value)
        
                return self.replyService
                    .saveScore(reply: replyCellViewModel.reply, score: replyScore)
            }
        
        let replyCellDidUpdate = _replyWithNewScore
            .withLatestFrom(_shouldSaveScore) { (replyAndNewScore, viewModels) -> CellViewModel in
                let reply = replyAndNewScore.0
                let userScore = replyAndNewScore.1
                let replyCellViewModel = viewModels.0
                let newScoreCellViewModels =
                    self.createScoreCellViewModels(for: reply,
                                                   userDidReply: true,
                                                   userScore: userScore)
        
                return CellViewModel(reply: reply,
                                     index: replyCellViewModel.index,
                                     scoreCellViewModels: newScoreCellViewModels,
                                     userDidReply: true,
                                     userScore: userScore)
            }
            .do(onNext: { self._replies.value[$0.index] = $0 })

        let createReply = input
            .createReplyTrigger
            .do(onNext: { self.router.toCreateReply(for: self.prompt) })
        
        let dismiss = input.backTrigger.do(onNext: router.toPrompts)
        
        return Output(replies: _replies.asDriver(),
                      createReply: createReply,
                      saveScore: replyCellDidUpdate,
                      dismissViewController: dismiss,
                      fetching: fetching,
                      errors: errors,
                      didBindReplies: didBindReplies)
    }
    
    //MARK: - Helper Methods
    
    private func createReplyCellViewModels(with replies: [PromptReply]) -> [CellViewModel] {
        return replies.enumerated().map { index, reply in
            let userScore = self.fetchCurrentUserScoreIfExists(for: reply, currentUserId: user.id)
            let userDidReply = (userScore != nil) ? true : false
            let scoreCellViewModels =
                createScoreCellViewModels(for: reply,
                                          userDidReply: userDidReply,
                                          userScore: userScore)
            return CellViewModel(reply: reply,
                                 index: index,
                                 scoreCellViewModels: scoreCellViewModels,
                                 userDidReply: userDidReply,
                                 userScore: userScore)
        }
    }
    
    private func createScoreCellViewModels(for reply: PromptReply,
                                   userDidReply: Bool,
                                   userScore: ReplyScore?) -> [ScoreCellViewModel] {
        return [#imageLiteral(resourceName: "IC_Score_One_Unselected"), #imageLiteral(resourceName: "IC_Score_Two_Unselected"), #imageLiteral(resourceName: "IC_Score_Three_Unselected"), #imageLiteral(resourceName: "IC_Score_Four_Unselected"), #imageLiteral(resourceName: "IC_Score_Five_Unselected")].enumerated().map {
                let scoreValue = $0.offset + 1
                return ScoreCellViewModel(value: scoreValue,
                                          reply: reply,
                                          userDidReply: userDidReply,
                                          placeholderImage: $0.element,
                                          userScore: userScore,
                                          percentage: self.scorePercentage(for: reply, scoreValue: scoreValue))
        }
    }
    
    private func fetchCurrentUserScoreIfExists(for reply: PromptReply,
                                               currentUserId: String) -> ReplyScore? {
        let score = reply.scores
            .filter(NSPredicate(format: "userId = %@", currentUserId)).first
        return score ?? nil
    }
    
    private func scorePercentage(for reply: PromptReply,
                                          scoreValue: Int) -> String {
        guard reply.scores.count > 0 else { return "0" }
        let numberOfVotesForScore = reply.scores
            .filter(NSPredicate(format: "score == %i", scoreValue))
        guard numberOfVotesForScore.count > 0 else { return "0" }
        print("votes for score: \(numberOfVotesForScore.count)")
        print("total score: \(reply.scores.count)")
        let value = (Double(numberOfVotesForScore.count) / Double(reply.scores.count))
        print("Value: \(value)")
        return "\(value.roundTo(decimalPlaces: 2)) %"
    }
    
}

extension Double {
    func roundTo(decimalPlaces: Int) -> String {
        return String(format: "%.\(decimalPlaces)f", self)
    }
}

