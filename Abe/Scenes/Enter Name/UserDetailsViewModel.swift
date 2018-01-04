
import Foundation
import RxSwift
import RxCocoa
import RealmSwift

final class UserDetailsViewModel: ViewModelType {
    
    struct Input {
        let firstName: Driver<String>
        let lastName: Driver<String>
        let nextTapped: Driver<Void>
    }
    
    struct Output {
        let inputIsValid: Driver<Bool>
        let routeToNextVc: Driver<Void>
    }
    
    private let router: UserDetailsRoutingLogic
    
    init(router: UserDetailsRoutingLogic) {
        self.router = router
    }
    
    func transform(input: Input) -> Output {
        
        let _combinedInput = Driver
            .combineLatest(input.firstName, input.lastName) { (first: $0, last: $1) }
        
        let inputIsValid = _combinedInput
            .map { $0.first.count > 3 && $0.last.count > 3 }
    
        let routeToNextVc = input.nextTapped
            .withLatestFrom(_combinedInput)
            .do(onNext: { UserDefaultsManager.saveSignUpName(name: $0) })
            .mapToVoid()
            .do(onNext: router.toPhoneEntry)
        
        return Output(inputIsValid: inputIsValid,
                      routeToNextVc: routeToNextVc)
    }
    
}
