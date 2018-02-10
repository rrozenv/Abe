
import Foundation
import RxSwift
import RxCocoa
import RxOptional

protocol SignupLoginViewModelInputs {
    var signupButtonTappedInput: AnyObserver<Void> { get }
    var loginButtonTappedInput: AnyObserver<Void> { get }
}

protocol SignupLoginViewModelType {
    var inputs: SignupLoginViewModelInputs { get }
}

final class SignupLoginViewModel: SignupLoginViewModelType, SignupLoginViewModelInputs {
    
    let disposeBag = DisposeBag()
    
//MARK: - Inputs
    var inputs: SignupLoginViewModelInputs { return self }
    let signupButtonTappedInput: AnyObserver<Void>
    let loginButtonTappedInput: AnyObserver<Void>
    
//MARK: - Init
    init(router: SignupLoginRoutingLogic) {
    
//MARK: - Subjects
        let _signupTappedInput = PublishSubject<Void>()
        let _loginTappedInput = PublishSubject<Void>()
        
//MARK: - Observers
        self.loginButtonTappedInput = _loginTappedInput.asObserver()
        self.signupButtonTappedInput = _signupTappedInput.asObserver()
        
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
