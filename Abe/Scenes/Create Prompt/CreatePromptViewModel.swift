
import Foundation
import RxSwift
import RxCocoa
import Action
import RealmSwift

final class CreatePromptViewModel: ViewModelType {
    
    struct Input {
        let title: Observable<String>
        let body: Observable<String>
        let createPromptTrigger: Observable<Void>
        let cancelTrigger: Driver<Void>
    }
    
    struct Output {
        let inputIsValid: Driver<Bool>
        let dismissViewController: Driver<Void>
    }
    
    private let promptService: PromptService
    private let userService: UserService
    private let router: CreatePromptRouter
    
    init(promptService: PromptService,
         userService: UserService,
         router: CreatePromptRouter) {
        self.promptService = promptService
        self.userService = userService
        self.router = router
    }
    
    func transform(input: Input) -> Output {
        
        //TODO: Force logout if Syncuser is nil
        
        //1. Output - Checks if done button is enabled
        let inputIsValid = Observable
            .combineLatest(input.title, input.body) { (title, body) in
                return title.count > 10 && body.count > 10
            }
            .asDriver(onErrorJustReturn: false)
        
        //2. Output - Dismisses VC when a new prompt is saved OR
        //            back button is tapped
        let _user = self.userService.fetchUserFor(key: SyncUser.current!.identity!)
        
        let _promptInputs = Observable
            .combineLatest(_user, input.title, input.body) {
                (user: $0, title: $1, body: $2)
            }
        
        let _createPrompt = input.createPromptTrigger
            .withLatestFrom(_promptInputs)
            .flatMapLatest { [unowned self] in
                return self.promptService
                    .createPrompt(title: $0.title, body: $0.body, user: $0.user)
            }
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        
        let dismiss = Driver.of(_createPrompt, input.cancelTrigger)
            .merge()
            .do(onNext: router.toPrompts)
        
        return Output(inputIsValid: inputIsValid,
                      dismissViewController: dismiss)
    }
    
}
