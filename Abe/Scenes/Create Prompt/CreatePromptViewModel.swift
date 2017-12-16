
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

    private let realm: RealmInstance
    private let router: CreatePromptRouter
    
    init(realm: RealmInstance, router: CreatePromptRouter) {
        self.realm = realm
        self.router = router
    }
    
    func transform(input: Input) -> Output {
        let inputIsValid = Observable.combineLatest(input.title, input.body) { (title, body) in
            return title.count > 10 && body.count > 10
        }
        .asDriver(onErrorJustReturn: false)
        
        let userInputs = Observable.combineLatest(input.title, input.body) { (title: $0, body: $1) }
        
        let createPrompt = input.createPromptTrigger
            .withLatestFrom(userInputs)
            .map { Prompt(title: $0.title, body: $0.body) }
            .flatMapLatest { [unowned self] prompt in
                self.realm.create(Prompt.self, value: prompt.value)
            }
            .mapToVoid()
            .asDriverOnErrorJustComplete()
    
        let dismiss = Driver.of(createPrompt, input.cancelTrigger)
            .merge()
            .do(onNext: router.toPrompts)
        
        return Output(inputIsValid: inputIsValid, dismissViewController: dismiss)
    }

}
