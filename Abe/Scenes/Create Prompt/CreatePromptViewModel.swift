
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
    private let router: CreatePromptRouter
    private let user: User
    
    init(promptService: PromptService,
         router: CreatePromptRouter) {
        guard let user = Application.shared.currentUser else { fatalError() }
        self.user = user
        self.promptService = promptService
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
        let _promptInputs = Observable
            .combineLatest(input.title, input.body) { (title: $0, body: $1) }
        
        let _createPrompt = input.createPromptTrigger
            .withLatestFrom(_promptInputs)
            .flatMapLatest { [unowned self] in
                return self.promptService
                    .createPrompt(title: $0.title, body: $0.body, user: self.user)
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
