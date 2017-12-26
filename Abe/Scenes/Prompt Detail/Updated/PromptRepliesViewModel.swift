
import Foundation
import RxSwift
import RxCocoa
import RealmSwift
import RxRealm

//class PromptRepliesViewModel {
//    
//    struct Input {
//        let scoreSelected: PublishSubject<CellViewModel>
//    }
//    
//    struct Output {
//        let replies: Driver<[PromptReply]>
//    }
//    
//    // MARK: - Properties
//    
//    var querying: Driver<Bool> { return _querying.asDriver() }
//    var replies: Driver<[PromptReply]> { return _replies.asDriver() }
//    
//    // MARK: -
//    
//    private let _querying = Variable<Bool>(false)
//    private let _replies = Variable<[PromptReply]>([])
//    private let scoreImages = [#imageLiteral(resourceName: "IC_Score_One_Unselected"), #imageLiteral(resourceName: "IC_Score_Two_Unselected"), #imageLiteral(resourceName: "IC_Score_Three_Unselected"), #imageLiteral(resourceName: "IC_Score_Four_Unselected"), #imageLiteral(resourceName: "IC_Score_Five_Unselected")]
//    
//    // MARK: -
//    
//    var hasReplies: Bool { return numberOfReplies > 0 }
//    var numberOfReplies: Int { return _replies.value.count }
//    
//    // MARK: -
//    
//    private let disposeBag = DisposeBag()
//    
//    // MARK: - Initializtion
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
//        let predicate = NSPredicate(format: "promptId = %@", prompt.id)
//        
//        self.commonRealm
//            .fetchResults(PromptReply.self, with: predicate)
//            .map { $0.filter { $0.visibility == "all" } }
//            .bind(to: _replies)
//            .disposed(by: disposeBag)
//        
//        return Output(replies: _replies.asDriver())
//    }
//    
//    // MARK: - Public API
//    
//    func reply(at index: Int) -> PromptReply? {
//        guard index < _replies.value.count else { return nil }
//        return _replies.value[index]
//    }
//    
//    func viewModelForReply(at index: Int) -> CellViewModel? {
//        guard let reply = reply(at: index) else { return nil }
//        return createViewModel(for: reply)
//    }
//    
//    func viewModelForScore(at index: Int) -> ScoreCellViewModel? {
//        guard let reply = reply(at: index) else { return nil }
//        return createViewModelForScore(for: reply, at: index)
//    }
//    
//    // MARK: - Helper Methods
//    
//    private func createViewModel(for reply: PromptReply) -> CellViewModel {
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
//    private func createViewModelForScore(for reply: PromptReply,
//                                         at index: Int) -> ScoreCellViewModel {
//        let userScore = self.fetchCurrentUserScoreIfExists(for: reply, currentUserId: user.id)
//        let userDidReply = (userScore != nil) ? true : false
//        return ScoreCellViewModel(value: index + 1,
//                                  reply: reply,
//                                  userDidReply: userDidReply,
//                                  placeholderImage: scoreImages[index],
//                                  userScore: userScore)
//    }
//    
//    private func fetchCurrentUserScoreIfExists(for reply: PromptReply, currentUserId: String) -> ReplyScore? {
//        let score = reply.scores
//            .filter(NSPredicate(format: "userId = %@", currentUserId)).first
//        return score ?? nil
//    }
//    
//}

