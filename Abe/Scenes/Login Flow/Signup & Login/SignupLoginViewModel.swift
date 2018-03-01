
import Foundation
import RxSwift
import RxCocoa
import RxOptional

protocol SignupLoginViewModelInputs {
    var viewDidLoadInput: AnyObserver<Void> { get }
    var signupButtonTappedInput: AnyObserver<Void> { get }
    var loginButtonTappedInput: AnyObserver<Void> { get }
}

protocol SignupLoginViewModelOutputs {
    var welcomeText: Driver<(header: String, body: String)> { get }
}

protocol SignupLoginViewModelType {
    var inputs: SignupLoginViewModelInputs { get }
}

final class SignupLoginViewModel: SignupLoginViewModelType, SignupLoginViewModelInputs, SignupLoginViewModelOutputs {
    
    let disposeBag = DisposeBag()
    
//MARK: - Inputs
    var inputs: SignupLoginViewModelInputs { return self }
    let viewDidLoadInput: AnyObserver<Void>
    let signupButtonTappedInput: AnyObserver<Void>
    let loginButtonTappedInput: AnyObserver<Void>

//MARK: - Outputs
    var outputs: SignupLoginViewModelOutputs { return self }
    let welcomeText: Driver<(header: String, body: String)>
    
//MARK: - Init
    init(router: SignupLoginRoutingLogic) {
    
//MARK: - Subjects
        let _viewDidLoadInput = PublishSubject<Void>()
        let _signupTappedInput = PublishSubject<Void>()
        let _loginTappedInput = PublishSubject<Void>()
        
//MARK: - Observers
        self.viewDidLoadInput = _viewDidLoadInput.asObserver()
        self.loginButtonTappedInput = _loginTappedInput.asObserver()
        self.signupButtonTappedInput = _signupTappedInput.asObserver()
        
//MARK: - Outputs
        let headerText = "Welcome to Outpost!"
        let bodyText = "The year is 2075…You are the commander of an outpost on an alien planet. Do you have what it takes to build a thriving democracy?"
        self.welcomeText = _viewDidLoadInput.asObservable()
            .map { _ in (header: headerText, body: bodyText) }
            .asDriver(onErrorJustReturn: (header: "", body: ""))
        
//MARK: - Routing
        _signupTappedInput.asObservable()
            .do(onNext: router.toSignupFlow)
            .subscribe()
            .disposed(by: disposeBag)
        
        _loginTappedInput.asObservable()
            .do(onNext: router.toLoginFlow)
            .subscribe()
            .disposed(by: disposeBag)
    }
    
}
