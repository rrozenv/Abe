
import Foundation
import RxSwift
import RxCocoa
import RxOptional

struct PercentageGraphViewModel {
    let userScore: ReplyScore
    let orderedPercetages: [Double]
    let totalVotes: Int
}

protocol GuessAndWagerValidationViewModelInputs {
    var viewDidLoadInput: AnyObserver<Void> { get }
    var doneButtonTappedInput: AnyObserver<Void> { get }
}

protocol GuessAndWagerValidationViewModelOutputs {
    var unlockedReplyViewModel: Driver<ReplyViewModel> { get }
    var userCoinsAndWagerResult: Driver<(user: User, wager: Int, isCorrect: Bool)> { get }
    var isUserCorrect: Driver<(isCorrect: Bool, guessedUser: User)> { get }
    var replyScores: Driver<[ReplyScore]> { get }
    var percentageGraphInfo: Driver<PercentageGraphViewModel> { get }
    var isGuessedUserHidden: Driver<Bool> { get }
}

protocol GuessAndWagerValidationViewModelType {
    var inputs: GuessAndWagerValidationViewModelInputs { get }
    var outputs: GuessAndWagerValidationViewModelOutputs { get }
}

final class GuessAndWagerValidationViewModel: GuessAndWagerValidationViewModelInputs, GuessAndWagerValidationViewModelOutputs, GuessAndWagerValidationViewModelType {
    
    let disposeBag = DisposeBag()
    
//MARK: - Inputs
    var inputs: GuessAndWagerValidationViewModelInputs { return self }
    let viewDidLoadInput: AnyObserver<Void>
    let doneButtonTappedInput: AnyObserver<Void>
    
//MARK: - Outputs
    var outputs: GuessAndWagerValidationViewModelOutputs { return self }
    let unlockedReplyViewModel: Driver<ReplyViewModel>
    let userCoinsAndWagerResult: Driver<(user: User, wager: Int, isCorrect: Bool)>
    let replyScores: Driver<[ReplyScore]>
    let isUserCorrect: Driver<(isCorrect: Bool, guessedUser: User)>
    let percentageGraphInfo: Driver<PercentageGraphViewModel>
    let isGuessedUserHidden: Driver<Bool>
    
//MARK: - Init
    init?(reply: PromptReply,
          ratingScoreValue: Int,
          guessedUser: User?,
          wager: Int?,
          router: GuessAndWagerValidationRoutingLogic,
          userService: UserService = UserService(),
          replyService: ReplyService = ReplyService()) {
        
        guard let user = AppController.shared.currentUser.value else {
            NotificationCenter.default.post(name: Notification.Name.logout, object: nil)
            return nil
        }
        let currentUser = Variable<User>(user)
        
//MARK: - Subjects
        let _viewDidLoadInput = PublishSubject<Void>()
        let _doneButtonTappedInput = PublishSubject<Void>()
        
//MARK: - Observers
        self.viewDidLoadInput = _viewDidLoadInput.asObserver()
        self.doneButtonTappedInput = _doneButtonTappedInput.asObserver()
        
//MARK: - First Level Observables
        let viewDidLoadObservable = _viewDidLoadInput.asObservable()
        let doneButtonTappedObservable = _doneButtonTappedInput.asObservable()
        
//MARK: - Second Level Observables
        let isUserCorrectObservable = viewDidLoadObservable
            .filter { guessedUser != nil }
            .map { (isCorrect: reply.user!.id == guessedUser!.id, guessedUser: guessedUser!) }
            .share()
        
        let didSaveScoreObservable = viewDidLoadObservable.mapToVoid()
            .flatMap { replyService.updateAuthorCoinsFor(reply: reply, coins: ratingScoreValue) }
            .map { ReplyScore(userId: currentUser.value.id,
                              replyId: $0.id,
                              score: ratingScoreValue) }
            .flatMap { replyService.saveScore(reply: reply, score: $0) }
            .share()
        
//MARK: - Outputs
        self.isUserCorrect = isUserCorrectObservable.asDriverOnErrorJustComplete()
        self.isGuessedUserHidden = Driver.of(guessedUser == nil)
        
        self.percentageGraphInfo = didSaveScoreObservable
            .map { inputs in
                (
                [1, 2, 3, 4, 5].map { inputs.reply.percentageOfVotesCastesFor(scoreValue: $0) },
                inputs.score,
                reply.scores.count
                )
            }
            .map { percentages, score, totalVotes in
                PercentageGraphViewModel(userScore: score,
                                         orderedPercetages: percentages,
                                         totalVotes: totalVotes)
            }
            .asDriverOnErrorJustComplete()
        
        self.replyScores = didSaveScoreObservable
            .map { $0.reply.scores.toArray() }
            .asDriver(onErrorJustReturn: [])
            
        self.unlockedReplyViewModel = Observable.of(reply)
            .map { ($0, ReplyScore(userId: currentUser.value.id,
                              replyId: reply.id,
                              score: ratingScoreValue)) }
            .map { ReplyViewModel(reply: $0, ratingScore: $1, isCurrentUsersFriend: true, isUnlocked: true) }
            .asDriverOnErrorJustComplete()
        
        self.userCoinsAndWagerResult = isUserCorrectObservable
            .filter { _ in wager != nil }
            .map { $0.isCorrect }
            .flatMap {
                userService.updateCoinsFor(user: currentUser.value,
                                           wager: $0 ? wager! * 2 : wager!,
                                           shouldAdd: $0 ? true : false)
            }
            .asDriver(onErrorDriveWith: Driver.never())
        
//MARK: - Routing
        doneButtonTappedObservable
            .do(onNext: router.toPromptDetail)
            .subscribe()
            .disposed(by: disposeBag)
    }
    
}

extension Driver {
    
    func flatMapOnBackground<R>(scheduler: SchedulerType, work: @escaping (Element) -> R) -> Driver<R> {
        return self.flatMapLatest { x in
            Observable.just(x)
                .observeOn(scheduler)
                .map(work)
                .asDriver(onErrorDriveWith: Driver<R>.never())
        }
    }
    
}
