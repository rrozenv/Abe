
import Foundation
import RxSwift
import RxCocoa
import RealmSwift
import RxSwiftExt
import PhoneNumberKit

struct PhoneEntryViewModel {
    
    struct Input {
        let phoneNumber: Driver<String>
        let doneTapped: Driver<Void>
    }
    
    struct Output {
        let entryIsValid: Driver<Bool>
        let didCreateUser: Driver<Void>
        let errors: Driver<Error>
    }

    private let phoneValidator = PhoneNumberValidator()
    private let userService: UserService
    private let userName: String
    private let router: PhoneEntryRoutingLogic
    
    init(userService: UserService,
         router: PhoneEntryRoutingLogic) {
        guard let userName = UserDefaultsManager.userName() else { fatalError() }
        self.userName = userName.first + " " + userName.last
        self.userService = userService
        self.router = router
    }
    
    func transform(input: Input) -> Output {
        let errorTracker = ErrorTracker()
        let activityTracker = ActivityIndicator()
        //let loading = activityTracker.asDriver()
        let errors = errorTracker.asDriver()
        
        let _numberInput = input.phoneNumber
        
        let entryIsValid = _numberInput
            .map { $0.count > 7 }
        
        let _verifyNumber = input.doneTapped
            .withLatestFrom(_numberInput)
            .flatMapLatest { number -> Driver<(valid: Bool, number: PhoneNumber)> in
                self.phoneValidator.validateNumber(number)
                    .trackError(errorTracker)
                    .asDriver(onErrorJustReturn: (valid: false, number: PhoneNumber.notPhoneNumber()))
            }
        
        let _verifiedNumber = _verifyNumber.asObservable()
            .filter { $0.valid }
            .map { $0.number }
            
        let _registerAuthorization = _verifiedNumber
            .flatMap {
                RealmAuth.authorize(email: $0.numberString,
                                    password: $0.numberString,
                                    register: true)
                .trackError(errorTracker)
                .trackActivity(activityTracker)
                .materialize()
            }
        
        let didCreateUser = _registerAuthorization.elements()
            .withLatestFrom(_verifiedNumber, resultSelector: { (syncUser: $0, number: $1) })
            .flatMapLatest {
                self.userService.createUser(syncUser: $0.syncUser,
                                            name: self.userName,
                                            email: $0.number.numberString,
                                            phoneNumber: $0.number.numberString)
            }
            .do(onNext: { Application.shared.currentUser.value = $0 })
            .mapToVoid()
            .do(onNext: router.toHome)
            .asDriverOnErrorJustComplete()
        
        return Output(entryIsValid: entryIsValid,
                      didCreateUser: didCreateUser,
                      errors: errors)
    }
    
}


final class PhoneNumberValidator {
    
    private let phoneNumberKit = PhoneNumberKit()
    
    func validateNumber(_ number: String) ->
        Observable<(valid: Bool, number: PhoneNumber)> {
        return Observable.create { (observer) in
            do {
                let phoneNumber = try self.phoneNumberKit.parse(number)
                observer.onNext((valid: true, number: phoneNumber))
                observer.onCompleted()
            }
            catch {
                observer.onError(PhoneNumberError.generalError)
            }
            return Disposables.create()
        }
    }
    
}

