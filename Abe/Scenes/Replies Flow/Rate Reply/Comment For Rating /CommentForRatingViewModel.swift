
import Foundation
import RxSwift
import RxCocoa

protocol CommentForRatingViewModelInputs {
    var viewWillAppearInput: AnyObserver<Void> { get }
    var bodyTextInput: AnyObserver<String> { get }
    var nextButtonTappedInput: AnyObserver<Void> { get }
    var backButtonTappedInput: AnyObserver<Void> { get }
}

protocol CommentForRatingModelOutputs {
    var nextButtonTitle: Driver<String> { get }
    var nextButtonIsEnabled: Driver<Bool> { get }
    var pageIndicator: Driver<(current: Int, total: Int)> { get }
    var reply: Driver<PromptReply> { get }
}

protocol CommentForRatingViewModelType {
    var inputs: CommentForRatingViewModelInputs { get }
    var outputs: CommentForRatingModelOutputs { get }
}

final class CommentForRatingViewModel: CommentForRatingViewModelInputs, CommentForRatingModelOutputs, CommentForRatingViewModelType {
    
    let disposeBag = DisposeBag()
    
    //MARK: - Inputs
    var inputs: CommentForRatingViewModelInputs { return self }
    let viewWillAppearInput: AnyObserver<Void>
    let bodyTextInput: AnyObserver<String>
    let nextButtonTappedInput: AnyObserver<Void>
    let backButtonTappedInput: AnyObserver<Void>
    
    //MARK: - Outputs
    var outputs: CommentForRatingModelOutputs { return self }
    let nextButtonTitle: Driver<String>
    let nextButtonIsEnabled: Driver<Bool>
    let pageIndicator: Driver<(current: Int, total: Int)>
    let reply: Driver<PromptReply>
    
    //MARK: - Init
    init?(reply: PromptReply,
          ratingScore: Int,
          isCurrentUsersFriend: Bool,
          router: CommentForRatingRoutingLogic) {
        
        guard let user = AppController.shared.currentUser.value else {
            NotificationCenter.default.post(name: Notification.Name.logout, object: nil)
            return nil
        }
        let currentUser = Variable<User>(user)
        
        //MARK: - Subjects
        let _viewWillAppearInput = PublishSubject<Void>()
        let _bodyTextInput = PublishSubject<String>()
        let _nextButtonTappedInput = PublishSubject<Void>()
        let _backButtonTappedInput = PublishSubject<Void>()
        
        //MARK: - Observers
        self.viewWillAppearInput = _viewWillAppearInput.asObserver()
        self.bodyTextInput = _bodyTextInput.asObserver()
        self.nextButtonTappedInput = _nextButtonTappedInput.asObserver()
        self.backButtonTappedInput = _backButtonTappedInput.asObserver()
        
        //MARK: - First Level Observables
        let viewWillAppearObservable = _viewWillAppearInput.asObservable()
        let bodyTextObservable = _bodyTextInput.asObservable()
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
        
        //MARK: - Outputs
        self.reply = Driver.of(reply)
        
        self.nextButtonTitle = isCurrentUsersFriendObservable
            .map { $0 ? "Next" : "Done" }
            .asDriverOnErrorJustComplete()
        
        self.pageIndicator = isCurrentUsersFriendObservable
            .map { (current: 1, total: $0 ? 4 : 2) }
            .asDriver(onErrorDriveWith: Driver.never())
        
        self.nextButtonIsEnabled = bodyTextObservable
            .map { $0.count > 10 }
            .asDriverOnErrorJustComplete()
        
        //MARK: - Routing
        backButtonTappedObservable
            .do(onNext: router.toPreviousViewController)
            .subscribe()
            .disposed(by: disposeBag)
        
        shouldRouteToSummaryVc
            .withLatestFrom(bodyTextObservable)
            .map { ReplyScore(user: currentUser.value,
                              replyId: reply.id,
                              score: ratingScore,
                              comment: $0) }
            .do(onNext: { router.toSummary(reply: reply, replyScore: $0) })
            .subscribe()
            .disposed(by: disposeBag)
        
        shouldRouteToGuessAuthorVc.mapToVoid()
            .withLatestFrom(bodyTextObservable)
            .map { ReplyScore(user: currentUser.value,
                              replyId: reply.id,
                              score: ratingScore,
                              comment: $0) }
            .do(onNext: { router.toGuessReplyAuthorFor(reply: reply, replyScore: $0) })
            .subscribe()
            .disposed(by: disposeBag)
    }
    
}
