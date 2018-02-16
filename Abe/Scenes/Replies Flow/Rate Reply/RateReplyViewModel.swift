
import Foundation
import RxSwift
import RxCocoa

struct RatingScoreViewModel {
    let value: Int
    let image: UIImage?
    let title: String?
    var isSelected: Bool
}

protocol RateReplyViewModelInputs {
    var viewWillAppearInput: AnyObserver<Void> { get }
    var selectedScoreInput: AnyObserver<RatingScoreViewModel> { get }
    var nextButtonTappedInput: AnyObserver<Void> { get }
    var backButtonTappedInput: AnyObserver<Void> { get }
}

protocol RateReplyViewModelOutputs {
    var ratingScores: Driver<[RatingScoreViewModel]> { get }
    var previousAndCurrentScore: Observable<(previous: RatingScoreViewModel, current: RatingScoreViewModel)> { get }
    var nextButtonTitle: Driver<String> { get }
    var nextButtonIsEnabled: Driver<Bool> { get }
    var currentPageIndicator: Driver<Int> { get }
    var reply: Driver<ReplyViewModel> { get }
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
    let selectedScoreInput: AnyObserver<RatingScoreViewModel>
    let nextButtonTappedInput: AnyObserver<Void>
    let backButtonTappedInput: AnyObserver<Void>
    
//MARK: - Outputs
    var outputs: RateReplyViewModelOutputs { return self }
    let ratingScores: Driver<[RatingScoreViewModel]>
    let previousAndCurrentScore: Observable<(previous: RatingScoreViewModel, current: RatingScoreViewModel)>
    let nextButtonTitle: Driver<String>
    let nextButtonIsEnabled: Driver<Bool>
    let currentPageIndicator: Driver<Int>
    let reply: Driver<ReplyViewModel>
    
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
        let _selectedScoreInput = PublishSubject<RatingScoreViewModel>()
        let _nextButtonTappedInput = PublishSubject<Void>()
        let _backButtonTappedInput = PublishSubject<Void>()
        
//MARK: - Observers
        self.viewWillAppearInput = _viewWillAppearInput.asObserver()
        self.selectedScoreInput = _selectedScoreInput.asObserver()
        self.nextButtonTappedInput = _nextButtonTappedInput.asObserver()
        self.backButtonTappedInput = _backButtonTappedInput.asObserver()
        
//MARK: - First Level Observables
        let viewWillAppearObservable = _viewWillAppearInput.asObservable()
        let selectedScoreObservable = _selectedScoreInput.asObservable()
            .startWith(RatingScoreViewModel(value: 0, image: nil, title: nil, isSelected: false))
        let isCurrentUsersFriendObservable = viewWillAppearObservable
            .map { _ in isCurrentUsersFriend }.share()
        let nextButtonTappedObservable = _nextButtonTappedInput.asObservable()
        let backButtonTappedObservable = _backButtonTappedInput.asObservable()
        
//MARK: - Second Level Observables
        let shouldRouteToGuessAuthorVc = nextButtonTappedObservable
            .withLatestFrom(isCurrentUsersFriendObservable)
            .filter { $0 } 
        let shouldRouteToSummaryVc = nextButtonTappedObservable
            .withLatestFrom(isCurrentUsersFriendObservable)
            .filter { !$0 }
        
//MARK: - Third Level Observables
//        let didSaveReplyScoreObservable = shouldDismissNavVCObservable.mapToVoid()
//            .withLatestFrom(selectedScoreObservable)
//            .map { ReplyScore(userId: currentUser.value.id,
//                              replyId: reply.id,
//                              score: $0.value) }
//            .flatMap { replyService.saveScore(reply: reply, score: $0) }
//            .flatMap { replyService.updateAuthorCoinsFor(reply: $0.0, coins: $0.1.score) }
        
//MARK: - Outputs
        self.reply = Driver.of(reply)
            .map { ReplyViewModel(reply: $0, ratingScore: nil, isCurrentUsersFriend: isCurrentUsersFriend, isUnlocked: false) }
        
        self.ratingScores = Observable.of([1, 2, 3, 4, 5].map {
            RatingScoreViewModel(value: $0,
                                 image: imageForRating(value: $0),
                                 title: titleForRating(value: $0),
                                 isSelected: false)
        })
        .asDriverOnErrorJustComplete()
        
        self.previousAndCurrentScore = Observable
            .zip(selectedScoreObservable, selectedScoreObservable.skip(1)) {
                (previous: $0, current: $1)
        }
        
        self.nextButtonTitle = isCurrentUsersFriendObservable
            .map { $0 ? "Next" : "Done" }
            .asDriverOnErrorJustComplete()
        
        self.currentPageIndicator = isCurrentUsersFriendObservable
            .map { $0 ? 0 : -1 }
            .asDriver(onErrorDriveWith: Driver.never())
        
        self.nextButtonIsEnabled = selectedScoreObservable
            .skip(1)
            .map { _ in true }
            .asDriverOnErrorJustComplete()
        
//MARK: - Routing
        backButtonTappedObservable
            .do(onNext: router.toPromptDetail)
            .subscribe()
            .disposed(by: disposeBag)
        
        shouldRouteToSummaryVc
            .withLatestFrom(selectedScoreObservable)
            .do(onNext: { router.toSummary(reply: reply, ratingScoreValue: $0.value) })
            .subscribe()
            .disposed(by: disposeBag)
        
        shouldRouteToGuessAuthorVc.mapToVoid()
            .withLatestFrom(selectedScoreObservable)
            .do(onNext: { router.toGuessReplyAuthorFor(reply: reply, ratingScoreValue: $0.value) })
            .subscribe()
            .disposed(by: disposeBag)
    }
    
}

private func imageForRating(value: Int) -> UIImage {
    switch value {
    case 1: return #imageLiteral(resourceName: "IC_AngryEmoji")
    case 2: return #imageLiteral(resourceName: "IC_ToungeEmoji")
    case 3: return #imageLiteral(resourceName: "IC_SmirkEmoji")
    case 4: return #imageLiteral(resourceName: "IC_HappyEmoji")
    case 5: return #imageLiteral(resourceName: "IC_LoveEmoji")
    default: return #imageLiteral(resourceName: "IC_ToungeEmoji")
    }
}

private func titleForRating(value: Int) -> String {
    switch value {
    case 1: return "Not Cool"
    case 2: return "I'm Dead"
    case 3: return "Hmmm...Okay"
    case 4: return "Yea Spot on!"
    case 5: return "Run For President"
    default: return "Idk"
    }
}
