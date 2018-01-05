
import Foundation
import RxSwift
import RxCocoa
import RealmSwift
import RxRealm
import RxSwiftExt

struct CellViewModel {
    let reply: PromptReply
    let userName: String
    let index: Int
    let scoreCellViewModels: [ScoreCellViewModel]
    let userDidReply: Bool
    let userScore: ReplyScore?
}

typealias ReplyChangeSet = (AnyRealmCollection<PromptReply>, RealmChangeset?)

struct PromptDetailViewModel {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    private let _replies = Variable<[CellViewModel]>([])
    
    // MARK: -
    struct Input {
        let viewDidLoad: Observable<Void>
        let userUpdatedNotification: Observable<Void>
        let viewWillAppear: Observable<Void>
        let visibilitySelected: Driver<Visibility>
        let createReplyTrigger: Driver<Void>
        let backTrigger: Driver<Void>
        let scoreSelected: PublishSubject<(CellViewModel, ScoreCellViewModel)>
    }
    
    struct Output {
        let replies: Driver<[CellViewModel]>
        let createReply: Driver<Void>
        let saveScore: Observable<CellViewModel>
        let shouldDisplayReplies: Driver<Bool>
        let dismissViewController: Driver<Void>
        let didUpdateUser: Observable<Void>
        let fetching: Driver<Bool>
        let errors: Driver<Error>
        let didBindReplies: Disposable
        let currentVisibility: Driver<Visibility>
    }
    
    private let prompt: Prompt
    private let router: PromptDetailRoutingLogic
    private let commonRealm: RealmInstance
    private let privateRealm: RealmInstance
    private let replyService: ReplyService
    private var user: Variable<User>
    
    init(commonRealm: RealmInstance,
         privateRealm: RealmInstance,
         replyService: ReplyService,
         prompt: Prompt,
         router: PromptDetailRoutingLogic) {
        guard let user = Application.shared.currentUser.value else { fatalError() }
        self.user = Variable<User>(user)
        self.prompt = prompt
        self.router = router
        self.commonRealm = commonRealm
        self.privateRealm = privateRealm
        self.replyService = replyService
    }
    
    func transform(input: Input) -> Output {
        let activityIndicator = ActivityIndicator()
        let errorTracker = ErrorTracker()
        let fetching = activityIndicator.asDriver()
        let errors = errorTracker.asDriver()
    
        let predicate = NSPredicate(format: "promptId = %@", prompt.id)
        
        let currentVisibility = input.visibilitySelected
        
        let didUpdateUser = input.userUpdatedNotification
            .do(onNext: { _ in
                self.user.value = Application.shared.currentUser.value!
            })
            .do(onNext: { _ in print("user has: \(self.user.value.replies.count) replies")})
        
        let _visibilityWhenViewAppears = input.viewWillAppear
            .flatMap { input.visibilitySelected }
            .debug()
            .asDriverOnErrorJustComplete()
        
        let _visibilityToFetch = Driver
            .merge(_visibilityWhenViewAppears, input.visibilitySelected)
            .skip(1)
            .debug()
        
        let didUserReply = _visibilityToFetch
            .map { _ in self.checkIfReplied(to: self.prompt, userId: self.user.value.id) }
        
        let _allReplies = _visibilityToFetch
            .filter { $0 == Visibility.all }
            .map { _ in self.checkIfReplied(to: self.prompt, userId: self.user.value.id) }
            .filter { $0 }
            .flatMapLatest { _ in
                return self.replyService
                    .fetchRepliesWith(predicate: predicate)
                    .map {
                        $0.filter {
                            $0.visibility == Visibility.all.rawValue
                             && $0.user?.id != self.user.value.id
                        }
                    }
                    .trackActivity(activityIndicator)
                    .trackError(errorTracker)
                    .asDriver(onErrorJustReturn: [PromptReply]())
            }
            .map { self.createReplyCellViewModels(with: $0) }

        //MARK: - Contact Replies View Models
        let _contactReplies = _visibilityToFetch
            .filter { $0 == Visibility.contacts }
            .map { _ in self.checkIfReplied(to: self.prompt, userId: self.user.value.id) }
            .filter { $0 }
            .flatMapLatest { _ in
                return self.replyService
                    .fetchRepliesWith(predicate: predicate)
                    .map {
                        $0.filter {
                            $0.visibility == Visibility.contacts.rawValue
                                && $0.user?.id != self.user.value.id
                        }
                    }
                    .trackActivity(activityIndicator)
                    .trackError(errorTracker)
                    .asDriver(onErrorJustReturn: [PromptReply]())
            }
        
        let _userContactNumers = input.viewWillAppear.flatMapLatest { _ in
            return self.privateRealm
                .fetchAllResults(Contact.self)
                .map { $0.flatMap { $0.numbers } }
                .startWith([String]())
                .asDriver(onErrorJustReturn: [String]())
        }
        .asDriverOnErrorJustComplete()
    
        let _filteredContactReplies = Driver
            .combineLatest(_contactReplies, _userContactNumers) { (replies, userNumbers) -> [PromptReply] in
                return replies.filter { (reply) in
                    guard let replyUserPhone = reply.user?.phoneNumber else { return false }
                    return userNumbers.contains(replyUserPhone)
                }
            }
            .map {
                self.createReplyCellViewModels(with: $0)
            }
        
        let _userReply = _visibilityToFetch.asObservable()
            .filter { $0 == Visibility.userReply }
            .flatMap { _ in self.fetchUserReply(for: self.prompt) }
            .unwrap()
            .map { self.createReplyCellViewModels(with: [$0]) }
            .asDriver(onErrorJustReturn: [CellViewModel]())

        //MARK: - Bind Replies
        //All replies must come LAST because they are shown FIRST
        let didBindReplies = Observable.of(_filteredContactReplies, _userReply, _allReplies)
            .merge()
            .bind(to: self._replies)
        
        //MARK: - Save Score
        let _shouldSaveScore = input.scoreSelected.asObservable()
            .filter { (replyCellViewModel, _)  in !replyCellViewModel.userDidReply }
        
        let _replyWithNewScore = _shouldSaveScore
            .flatMapLatest { (viewModels) -> Observable<(PromptReply, ReplyScore)> in
                let replyCellViewModel = viewModels.0
                let scoreCellViewModel = viewModels.1
                let replyScore = ReplyScore(userId: self.user.value.id,
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
                let userName = self.setUserName(for: reply,
                                                visibility: reply.visibility,
                                                didReply: true)
                let newScoreCellViewModels =
                    self.createScoreCellViewModels(for: reply,
                                                   userDidReply: true,
                                                   userScore: userScore)
        
                return CellViewModel(reply: reply,
                                     userName: userName,
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
                      shouldDisplayReplies: didUserReply,
                      dismissViewController: dismiss,
                      didUpdateUser: didUpdateUser,
                      fetching: fetching,
                      errors: errors,
                      didBindReplies: didBindReplies,
                      currentVisibility: currentVisibility)
    }
    
    //MARK: - Helper Methods
    
    private func checkIfUserReplied(to prompt: Prompt, userId: String) -> Observable<Bool> {
        let userReplies = self.prompt.replies.filter { $0.user?.id == userId }
        print(userReplies.count)
        return .just(userReplies.count >= 1)
    }
    
    private func checkIfReplied(to prompt: Prompt, userId: String) -> Bool {
        let predicate = NSPredicate(format: "promptId = %@", prompt.id)
        let userReplies = self.user.value.replies.filter(predicate)
        //let userReplies = self.prompt.replies.filter { $0.user?.id == userId }
        return userReplies.count > 0
    }
    
    private func fetchUserReply(for prompt: Prompt) -> Observable<PromptReply?> {
        let predicate = NSPredicate(format: "promptId = %@", prompt.id)
        let userReplies = self.user.value.replies.filter(predicate)
        //let userReplies = self.prompt.replies.filter { $0.user?.id == userId }
        return Observable.of(userReplies.first)
    }
    
    private func createReplyCellViewModels(with replies: [PromptReply]) -> [CellViewModel] {
        guard !replies.isEmpty else { return [CellViewModel]() }
        return replies.enumerated().map { index, reply in
            let userScore = self.fetchCurrentUserScoreIfExists(for: reply, currentUserId: self.user.value.id)
            let userDidReply = (userScore != nil) ? true : false
            let userName = self.setUserName(for: reply, visibility: reply.visibility, didReply: userDidReply)
            let scoreCellViewModels =
                createScoreCellViewModels(for: reply,
                                          userDidReply: userDidReply,
                                          userScore: userScore)
            return CellViewModel(reply: reply,
                                 userName: userName,
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
        let value = (Double(numberOfVotesForScore.count) / Double(reply.scores.count))
        return "\(value.roundTo(decimalPlaces: 2)) %"
    }
    
    private func setUserName(for reply: PromptReply,
                             visibility: String,
                             didReply: Bool) -> String {
        switch (visibility, didReply) {
        case ("all", let didReply):
            return (didReply) ? reply.user!.name : "Someone said..."
        case ("contacts", let didReply):
            return (didReply) ? reply.user!.name : "Someone from contacts said..."
        default:
            return reply.user!.name
        }
    }
    
}

extension Double {
    func roundTo(decimalPlaces: Int) -> String {
        return String(format: "%.\(decimalPlaces)f", self)
    }
}

