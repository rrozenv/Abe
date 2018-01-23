
import Foundation
import RxSwift
import RxCocoa

struct RatingScore {
    let value: Int
    var isSelected: Bool
}

protocol RateReplyViewModelInputs {
    var viewWillAppearInput: AnyObserver<Void> { get }
    var selectedScoreInput: AnyObserver<RatingScore> { get }
    var nextButtonTappedInput: AnyObserver<Void> { get }
}

protocol RateReplyViewModelOutputs {
    var ratingScores: Driver<[RatingScore]> { get }
    var previousAndCurrentScore: Observable<(previous: RatingScore, current: RatingScore)> { get }
    var nextButtonTitle: Driver<String> { get }
    var nextButtonIsEnabled: Driver<Bool> { get }
}

protocol RateReplyViewModelType {
    var inputs: RateReplyViewModelInputs { get }
    var outputs: RateReplyViewModelOutputs { get }
}

final class RateReplyViewModel: RateReplyViewModelInputs, RateReplyViewModelOutputs, RateReplyViewModelType {
    
    let disposeBag = DisposeBag()
    
//MARK: - Inputs
    var inputs: RateReplyViewModelInputs { return self }
    let viewWillAppearInput: AnyObserver<Void>
    let selectedScoreInput: AnyObserver<RatingScore>
    let nextButtonTappedInput: AnyObserver<Void>
    
//MARK: - Outputs
    var outputs: RateReplyViewModelOutputs { return self }
    let ratingScores: Driver<[RatingScore]>
    let previousAndCurrentScore: Observable<(previous: RatingScore, current: RatingScore)>
    let nextButtonTitle: Driver<String>
    let nextButtonIsEnabled: Driver<Bool>
    
//MARK: - Init
    init?(reply: PromptReply,
          replyService: ReplyService = ReplyService(),
          isCurrentUsersFriend: Bool,
          router: RateReplyRoutingLogic) {
        
        guard let user = AppController.shared.currentUser.value else {
            NotificationCenter.default.post(name: Notification.Name.logout, object: nil)
            return nil
        }
        let currentUser = Variable<User>(user)
   
//MARK: - Subjects
        let _viewWillAppearInput = PublishSubject<Void>()
        let _selectedScoreInput = PublishSubject<RatingScore>()
        let _nextButtonTappedInput = PublishSubject<Void>()
        
//MARK: - Observers
        self.viewWillAppearInput = _viewWillAppearInput.asObserver()
        self.selectedScoreInput = _selectedScoreInput.asObserver()
        self.nextButtonTappedInput = _nextButtonTappedInput.asObserver()
        
//MARK: - First Level Observables
        let viewWillAppearObservable = _viewWillAppearInput.asObservable()
        let selectedScoreObservable = _selectedScoreInput.asObservable()
            .startWith(RatingScore(value: 0, isSelected: false))
        let isCurrentUsersFriendObservable = Observable.of(isCurrentUsersFriend)
        let nextButtonTappedObservable = _nextButtonTappedInput.asObservable()
        
//MARK: - Second Level Observables
        let shouldRouteToNextNavVCObservable = nextButtonTappedObservable
            .withLatestFrom(isCurrentUsersFriendObservable)
            .filter { $0 }
        let shouldDismissNavVCObservable = nextButtonTappedObservable
            .withLatestFrom(isCurrentUsersFriendObservable)
            .filter { !$0 }
        
//MARK: - Third Level Observables
        let didSaveReplyScoreObservable = shouldDismissNavVCObservable.mapToVoid()
            .withLatestFrom(selectedScoreObservable)
            .map { ReplyScore(userId: currentUser.value.id,
                              replyId: reply.id,
                              score: $0.value) }
            .flatMap { replyService.saveScore(reply: reply, score: $0) }
            .flatMap { replyService.updateAuthorCoinsFor(reply: $0.0, coins: $0.1.score) }
        
//MARK: - Outputs
        self.ratingScores = viewWillAppearObservable
            .map { _ in
                return [1, 2, 3, 4, 5].map { RatingScore(value: $0, isSelected: false) }
            }
            .asDriverOnErrorJustComplete()
        
        self.previousAndCurrentScore = Observable
            .zip(selectedScoreObservable, selectedScoreObservable.skip(1)) {
                (previous: $0, current: $1)
        }
        
        self.nextButtonTitle = isCurrentUsersFriendObservable
            .map { $0 ? "Next" : "Done" }
            .asDriverOnErrorJustComplete()
        
        self.nextButtonIsEnabled = selectedScoreObservable
            .skip(1)
            .map { _ in true }
            .asDriverOnErrorJustComplete()
        
//MARK: - Routing
        didSaveReplyScoreObservable.mapToVoid()
            .do(onNext: router.toPromptDetail)
            .subscribe()
            .disposed(by: disposeBag)
        
        shouldRouteToNextNavVCObservable.mapToVoid()
            .withLatestFrom(selectedScoreObservable)
            .do(onNext: { router.toGuessReplyAuthorFor(reply: reply, ratingScoreValue: $0.value) })
            .subscribe()
            .disposed(by: disposeBag)
    }
    
}
