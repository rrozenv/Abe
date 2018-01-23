
import Foundation
import RxSwift
import RxCocoa
import RxOptional

protocol GuessAndWagerValidationViewModelInputs {
    var viewDidLoadInput: AnyObserver<Void> { get }
}

protocol GuessAndWagerValidationViewModelOutputs {
    var unlockedReply: Driver<PromptReply> { get }
    var userCoinsAndWagerResult: Driver<(user: User, wager: Int, isCorrect: Bool)> { get }
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
    
//MARK: - Outputs
    var outputs: GuessAndWagerValidationViewModelOutputs { return self }
    let unlockedReply: Driver<PromptReply>
    let userCoinsAndWagerResult: Driver<(user: User, wager: Int, isCorrect: Bool)>
    let replyScores: Driver<[ReplyScore]>
    
//MARK: - Init
    init?(reply: PromptReply,
          ratingScoreValue: Int,
          guessedUser: User,
          wager: Int,
          userService: UserService = UserService(),
          replyService: ReplyService = ReplyService()) {
        
        guard let user = AppController.shared.currentUser.value else {
            NotificationCenter.default.post(name: Notification.Name.logout, object: nil)
            return nil
        }
        let currentUser = Variable<User>(user)
        
//MARK: - Subjects
        let _viewDidLoadInput = PublishSubject<Void>()
        
//MARK: - Observers
        self.viewDidLoadInput = _viewDidLoadInput.asObserver()
        
//MARK: - First Level Observables
        let viewDidLoadObservable = _viewDidLoadInput.asObservable()
        
//MARK: - Second Level Observables
        let isUserCorrectObservable = viewDidLoadObservable
            .map { reply.user!.id == guessedUser.id }
        
//MARK: - Outputs
        self.unlockedReply = Driver.of(reply)
        self.userCoinsAndWagerResult = isUserCorrectObservable
            .flatMap {
                userService.updateCoinsFor(user: currentUser.value,
                                           wager: $0 ? wager * 2 : wager,
                                           shouldAdd: $0 ? true : false)
            }
            .asDriver(onErrorDriveWith: Driver.never())
        
        let didSaveAndUpdateAuthorCoinsObservable =  viewDidLoadObservable
            .map { ReplyScore(user: currentUser.value,
                              replyId: reply.id,
                              score: ratingScoreValue) }
            .flatMap { replyService.saveScore(reply: reply, score: $0) }
            .flatMap { replyService.updateAuthorCoinsFor(reply: $0.0, coins: $0.1.score) }
        
       self.replyScores = didSaveAndUpdateAuthorCoinsObservable
        .map { $0.scores.toArray() }
        .asDriver(onErrorJustReturn: [])
        
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
