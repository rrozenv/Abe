

import Foundation
import RxSwift
import RxCocoa
import RealmSwift
import RxRealm

//struct RepliesFromContactsViewModel {
//    
//    // MARK: - Properties
//    
//    let disposeBag = DisposeBag()
//    
//    var querying: Driver<Bool> { return _querying.asDriver() }
//    var replies: Driver<[CellViewModel]> { return _replies.asDriver() }
//    
//    // MARK: -
//    
//    private let _querying = Variable<Bool>(false)
//    private let _replies = Variable<[CellViewModel]>([])
//    
//    var hasReplies: Bool { return numberOfReplies > 0 }
//    var numberOfReplies: Int { return _replies.value.count }
//    
//    struct Input {
//        let refreshTrigger: Driver<Void>
//        let scoreSelected: PublishSubject<(CellViewModel, ScoreCellViewModel)>
//    }
//    
//    struct Output {
//        let replies: Driver<[CellViewModel]>
//        let fetchReplies: Driver<Void>
//        let saveScore: Observable<CellViewModel>
//        let fetching: Driver<Bool>
//        let errors: Driver<Error>
//    }
//    
//    private let prompt: Prompt
//    private let router: PromptDetailRoutingLogic
//    private let commonRealm: RealmInstance
//    private let privateRealm: RealmInstance
//    private let user: UserInfo
//    
//    init(commonRealm: RealmInstance,
//         privateRealm: RealmInstance,
//         prompt: Prompt,
//         router: PromptDetailRoutingLogic) {
//        self.prompt = prompt
//        self.router = router
//        self.commonRealm = commonRealm
//        self.privateRealm = privateRealm
//        self.user = UserDefaultsManager.userInfo()!
//    }
//    
//    func transform(input: Input) -> Output {
//        let activityIndicator = ActivityIndicator()
//        let errorTracker = ErrorTracker()
//        let fetching = activityIndicator.asDriver()
//        let errors = errorTracker.asDriver()
//        
//        let predicate = NSPredicate(format: "promptId = %@", prompt.id)
//        
//        //1. Make sure replies
//        let _userContactNumers = self.privateRealm
//            .fetchAllResults(Contact.self)
//            .map { $0.flatMap { $0.numbers } }
//        
//        let _contactsReplies = self.commonRealm
//            .fetchResults(PromptReply.self, with: predicate)
//            .map { $0.filter { $0.visibility == "contacts" } }
//        
//        //        let _filteredContactReplies = Observable
//        //            .combineLatest(_user, _contactsReplies, _userContactNumers) { (user, replies, userNumbers) -> [PromptReply] in
//        //            return replies.filter {
//        //                guard let replyUserPhone = $0.user?.phoneNumber else { return false }
//        //                return userNumbers.contains(replyUserPhone)
//        //            }
//        //        }
//        //        .startWith([])
//        //        .asDriverOnErrorJustComplete()
//        //
//        //2. Replies marked all
//        let fetchReplies = input.refreshTrigger
//            .do(onNext: { _ in
//                self.commonRealm
//                    .fetchResults(PromptReply.self, with: predicate)
//                    .map { $0.filter { $0.visibility == "all" } }
//                    .map { self.createReplyCellViewModels(with: $0) }
//                    .trackError(errorTracker)
//                    .trackActivity(activityIndicator)
//                    .bind(to: self._replies)
//                    .disposed(by: self.disposeBag)
//            })
//        
//        let saveScore = input
//            .scoreSelected
//            .asObservable()
//            .filter { !$0.0.userDidReply }
//            .flatMap { (vm) -> Observable<CellViewModel> in
//                let replyScore = ReplyScore(userId: self.user.id,
//                                            replyId: vm.0.reply.id,
//                                            score: vm.1.value)
//                
//                self.commonRealm.updateWrite {
//                    vm.0.reply.scores.append(replyScore)
//                }
//                
//                return .just(CellViewModel(reply: vm.0.reply,
//                                           scoreCellViewModels: vm.0.scoreCellViewModels,
//                                           userDidReply: true,
//                                           userScore: replyScore))
//            }
//            .do(onNext: { (cellVm) in
//                let index = self._replies.value.index(where: { $0.reply.id == cellVm.reply.id })
//                self._replies.value[index!] = cellVm
//            })
//        
//        //2. Merged list
//        //        let finalizedReplyList = Observable
//        //            .of(_allReplies, _filteredContactReplies)
//        //            .merge()
//        //            .asDriverOnErrorJustComplete()
//        
//        let createReply = input
//            .createReplyTrigger
//            .do(onNext: { self.router.toCreateReply(for: self.prompt) })
//        
//        let dismiss = input.backTrigger.do(onNext: router.toPrompts)
//        
//        return Output(replies: _replies.asDriver(),
//                      fetchReplies: fetchReplies,
//                      createReply: createReply,
//                      saveScore: saveScore,
//                      dismissViewController: dismiss,
//                      fetching: fetching,
//                      errors: errors)
//    }
//    
//    private func createReplyCellViewModels(with replies: [PromptReply]) -> [CellViewModel] {
//        return replies.map { (reply) in
//            let userScore = self.fetchCurrentUserScoreIfExists(for: reply, currentUserId: user.id)
//            let userDidReply = (userScore != nil) ? true : false
//            let scoreCellViewModels =
//                createScoreCellViewModels(for: reply,
//                                          userDidReply: userDidReply,
//                                          userScore: userScore)
//            return CellViewModel(reply: reply,
//                                 scoreCellViewModels: scoreCellViewModels,
//                                 userDidReply: userDidReply,
//                                 userScore: userScore)
//        }
//    }
//    
//    private func createCellViewModel(with reply: PromptReply) -> CellViewModel {
//        let userScore = self.fetchCurrentUserScoreIfExists(for: reply, currentUserId: user.id)
//        let userDidReply = (userScore != nil) ? true : false
//        let scoreCellViewModels =
//            createScoreCellViewModels(for: reply,
//                                      userDidReply: userDidReply,
//                                      userScore: userScore)
//        return CellViewModel(reply: reply,
//                             scoreCellViewModels: scoreCellViewModels,
//                             userDidReply: userDidReply,
//                             userScore: userScore)
//    }
//    
//    private func createScoreCellViewModels(for reply: PromptReply,
//                                           userDidReply: Bool,
//                                           userScore: ReplyScore?) -> [ScoreCellViewModel] {
//        return [#imageLiteral(resourceName: "IC_Score_One_Unselected"), #imageLiteral(resourceName: "IC_Score_Two_Unselected"), #imageLiteral(resourceName: "IC_Score_Three_Unselected"), #imageLiteral(resourceName: "IC_Score_Four_Unselected"), #imageLiteral(resourceName: "IC_Score_Five_Unselected")].enumerated().map {
//            return ScoreCellViewModel(value: $0.offset + 1,
//                                      reply: reply,
//                                      userDidReply: userDidReply,
//                                      placeholderImage: $0.element,
//                                      userScore: userScore)
//        }
//    }
//    
//    private func fetchCurrentUserScoreIfExists(for reply: PromptReply,
//                                               currentUserId: String) -> ReplyScore? {
//        let score = reply.scores
//            .filter(NSPredicate(format: "userId = %@", currentUserId)).first
//        return score ?? nil
//    }
//    
//    
//}
