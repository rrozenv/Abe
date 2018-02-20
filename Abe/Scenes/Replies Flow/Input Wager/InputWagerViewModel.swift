
import Foundation
import RxSwift
import RxCocoa
import RxOptional

enum InputWagerError: Error {
    case notValidNumber
    case notEnoughCoins(total: Int)
    case greaterThanMaxAmount(max: Int)
    case emptyWager
}

protocol InputWagerViewModelInputs {
    var wagerTextInput: AnyObserver<String> { get }
    var doneTappedInput: AnyObserver<Void> { get }
    var backButtonTappedInput: AnyObserver<Void> { get }
    var skipButtonTappedInput: AnyObserver<Void> { get }
}

protocol InputWagerViewModelOutputs {
    var wagerError: Observable<InputWagerError> { get }
    var guessedUser: Driver<User> { get }
    var currentPageIndicator: Driver<Int> { get }
}

protocol InputWagerViewModelType {
    var inputs: InputWagerViewModelInputs { get }
    var outputs: InputWagerViewModelOutputs { get }
}

final class InputWagerViewModel: InputWagerViewModelInputs, InputWagerViewModelOutputs, InputWagerViewModelType {
    
    let disposeBag = DisposeBag()
    
//MARK: - Inputs
    var inputs: InputWagerViewModelInputs { return self }
    let wagerTextInput: AnyObserver<String>
    let doneTappedInput: AnyObserver<Void>
    let backButtonTappedInput: AnyObserver<Void>
    let skipButtonTappedInput: AnyObserver<Void>
    
//MARK: - Outputs
    var outputs: InputWagerViewModelOutputs { return self }
    let wagerError: Observable<InputWagerError>
    let guessedUser: Driver<User>
    let currentPageIndicator: Driver<Int>
    
//MARK: - Init
    init?(reply: PromptReply,
          guessedUser: User,
          replyScore: ReplyScore,
          router: InputWagerRoutingLogic) {
        
        guard let user = AppController.shared.currentUser.value else {
            NotificationCenter.default.post(name: Notification.Name.logout, object: nil)
            return nil
        }
        let currentUser = Variable<User>(user)
    
//MARK: - Subjects
        let _wagerTextInput = PublishSubject<String>()
        let _doneTappedInput = PublishSubject<Void>()
        let _backButtontTappedInput = PublishSubject<Void>()
        let _skipButtonTappedInput = PublishSubject<Void>()

//MARK: - Observers
        self.wagerTextInput = _wagerTextInput.asObserver()
        self.doneTappedInput = _doneTappedInput.asObserver()
        self.backButtonTappedInput = _backButtontTappedInput.asObserver()
        self.skipButtonTappedInput = _skipButtonTappedInput.asObserver()
        
//MARK: - First Level Observables
        let wagerTextObservable = _wagerTextInput.asObservable()
        let doneTappedObservable = _doneTappedInput.asObservable()
        let backTappedObservable = _backButtontTappedInput.asObservable()
        let skipTappedObservable = _skipButtonTappedInput.asObservable()
        let maxWagerAllowed = 100
        
//MARK: - Second Level Observables
        let emptyWagerErrorObservable = doneTappedObservable
            .withLatestFrom(wagerTextObservable)
            .filter { $0.isEmpty || $0 == "" }
            .map { _ in InputWagerError.emptyWager }
        let convertedToIntegarObservable = doneTappedObservable
            .withLatestFrom(wagerTextObservable)
            .filter { !$0.isEmpty || $0 != "" }
            .map { Int($0) }.unwrap()
        let notValidNumberErrorObservable = doneTappedObservable
            .withLatestFrom(wagerTextObservable)
            .filter { !$0.isEmpty || $0 != "" }
            .map { Int($0) }
            .filter { $0 == nil }
            .map { _ in InputWagerError.notValidNumber }
        
//MARK: - Third Level Observables
        let isInputValidObservable = convertedToIntegarObservable
            .map { (isValid: (currentUser.value.coins >= $0) && ($0 <= maxWagerAllowed), int: $0) }
        
//MARK: - Fourth Level Observables
        let notEnoughCoinsErrorObservable = isInputValidObservable
            .filter { !$0.isValid && $0.int <= maxWagerAllowed }
            .map { _ in InputWagerError.notEnoughCoins(total: currentUser.value.coins) }
        let greaterThanMaxErrorObservable = isInputValidObservable
            .filter { !$0.isValid && $0.int > maxWagerAllowed }
            .map { _ in InputWagerError.greaterThanMaxAmount(max: maxWagerAllowed) }
        
//MARK: - Outputs
        self.wagerError = Observable.of(emptyWagerErrorObservable,
                                        notEnoughCoinsErrorObservable,
                                        notValidNumberErrorObservable,
                                        greaterThanMaxErrorObservable).merge()
        
        self.guessedUser = Driver.of(guessedUser)
        self.currentPageIndicator = Driver.of(2)
        
//MARK: - Routing
        isInputValidObservable.filter { $0.isValid }
            .do(onNext: { router.toGuessAndWagerValidation(reply: reply,
                                                           replyScore: replyScore,
                                                           guessedUser: guessedUser,
                                                           wager: $0.int) })
            .subscribe()
            .disposed(by: disposeBag)
        
        skipTappedObservable
            .do(onNext: { router.toGuessAndWagerValidation(reply: reply,
                                                           replyScore: replyScore,
                                                           guessedUser: guessedUser,
                                                           wager: 0) })
            .subscribe()
            .disposed(by: disposeBag)
        
        backTappedObservable
            .do(onNext: router.toPreviousNavViewController)
            .subscribe()
            .disposed(by: disposeBag)
    }
    
}
