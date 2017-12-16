
import Foundation
import RxSwift
import RxCocoa
import Action
import RealmSwift
import RxSwiftExt

final class SignupViewModel {

    struct Input {
        let userName: Driver<String>
        let email: Driver<String>
        let password: Driver<String>
        let signUpTrigger: Observable<Void>
        let loginTrigger: Observable<Void>
    }
    
    struct Output {
        let userInputIsValid: Driver<Bool>
        let newUser: Driver<Void>
        let exisitingUser: Driver<Void>
        let loading: Driver<Bool>
        let errors: Driver<Error>
    }
    
    struct UserInput {
        let userName: String
        let email: String
        let password: String
    }
    
    private lazy var realm: RealmInstance = {
        return RealmInstance(configuration: RealmConfig.common)
    }()
    
    private let router: SignupRouter
    
    init(router: SignupRouter) {
        self.router = router
    }
    
    func transform(input: Input) -> Output {
    
        let errorTracker = ErrorTracker()
        let activityTracker = ActivityIndicator()
        let loading = activityTracker.asDriver()
        let errors = errorTracker.asDriver()
        
        let userInputIsValid = Driver.combineLatest(input.email, input.password, resultSelector: { (email, password) in
            return email.count > 3 && password.count > 3
        })
        
        let latestUserInput = Driver.combineLatest(input.userName, input.email, input.password, resultSelector: { (userName, email, password) in
            return UserInput(userName: userName.lowercased(),
                             email: email.lowercased(),
                             password: password.lowercased())
        })
        
     
        let register = input.signUpTrigger
            .withLatestFrom(latestUserInput)
            .flatMapLatest { (input) in
                return RealmAuth
                    .authorize(email: input.email, password: input.password, register: true)
                    .trackError(errorTracker)
                    .trackActivity(activityTracker)
                    .materialize()
            }
        
        let login = input.loginTrigger
            .withLatestFrom(latestUserInput)
            .flatMapLatest { (input) in
                return RealmAuth
                    .authorize(email: input.email, password: input.password, register: false)
                    .trackError(errorTracker)
                    .trackActivity(activityTracker)
                    .materialize()
            }
        
        let newUser = register.elements()
            .withLatestFrom(latestUserInput) { (syncUser, input) -> User in
                return User(syncUser: syncUser, name: input.userName, email: input.email)
            }
            .flatMapLatest { [unowned self] (user) in
                return self.realm.create(User.self, value: user.value)
            }
            .asDriverOnErrorJustComplete()
            .do(onNext: self.router.toHome)
        
        let existingUser = login.elements()
            .mapToVoid()
            .asDriverOnErrorJustComplete()
            .do(onNext: self.router.toHome)
        
        return Output(userInputIsValid: userInputIsValid,
                      newUser: newUser,
                      exisitingUser: existingUser,
                      loading: loading,
                      errors: errors)
    }
    
}

