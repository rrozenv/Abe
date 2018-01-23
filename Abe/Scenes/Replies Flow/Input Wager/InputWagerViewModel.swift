
import Foundation
import RxSwift
import RxCocoa
import RxOptional

enum InputWagerError: Error {
    case notValidNumber
    case notEnoughCoins(total: Int)
    case greaterThanMaxAmount(max: Int)
}

protocol InputWagerViewModelInputs {
    var wagerTextInput: AnyObserver<String> { get }
    var doneTappedInput: AnyObserver<Void> { get }
}

protocol InputWagerViewModelOutputs {
    var wagerError: Observable<InputWagerError> { get }
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
    
//MARK: - Outputs
    var outputs: InputWagerViewModelOutputs { return self }
    let wagerError: Observable<InputWagerError>
    
//MARK: - Init
    init?(reply: PromptReply,
          guessedUser: User) {
        
        guard let user = AppController.shared.currentUser.value else {
            NotificationCenter.default.post(name: Notification.Name.logout, object: nil)
            return nil
        }
        let currentUser = Variable<User>(user)
    
//MARK: - Subjects
        let _wagerTextInput = PublishSubject<String>()
        let _doneTappedInput = PublishSubject<Void>()
        
//MARK: - Observers
        self.wagerTextInput = _wagerTextInput.asObserver()
        self.doneTappedInput = _doneTappedInput.asObserver()
        
//MARK: - First Level Observables
        let wagerTextObservable = _wagerTextInput.asObservable()
        let doneTappedObservable = _doneTappedInput.asObservable()
        let maxWagerAllowed = 100
        
//MARK: - Second Level Observables
        let convertedToIntegarObservable = doneTappedObservable
            .withLatestFrom(wagerTextObservable)
            .map { Int($0) }.unwrap()
        let notValidNumberErrorObservable = doneTappedObservable
            .withLatestFrom(wagerTextObservable)
            .map { Int($0) }
            .filter { $0 == nil }
            .map { _ in InputWagerError.notValidNumber }
        
//MARK: - Third Level Observables
        let isInputValidObservable = convertedToIntegarObservable
            .map { (isValid: (currentUser.value.coins >= $0) && ($0 < maxWagerAllowed), int: $0) }
        
//MARK: - Fourth Level Observables
        let notEnoughCoinsErrorObservable = isInputValidObservable
            .filter { !$0.isValid && $0.int < maxWagerAllowed }
            .map { _ in InputWagerError.notEnoughCoins(total: currentUser.value.coins) }
        
        let greaterThanMaxErrorObservable = isInputValidObservable
            .filter { !$0.isValid && $0.int > maxWagerAllowed }
            .map { _ in InputWagerError.greaterThanMaxAmount(max: maxWagerAllowed) }
        
//MARK: - Outputs
        self.wagerError = Observable.of(notEnoughCoinsErrorObservable,
                                        notValidNumberErrorObservable,
                                        greaterThanMaxErrorObservable).merge()
        
        //MARK: - Routing
        isInputValidObservable.filter { $0.isValid }
            .do(onNext: { print("valid wager of \($0.int) coins selected") })
            .subscribe()
            .disposed(by: disposeBag)
        
    }
    
}
