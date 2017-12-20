
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
        let promptSaved: Driver<Void>
        let dismissViewController: Driver<Void>
    }
    
    private lazy var realmT: Realm = {
        return try! Realm(configuration: RealmConfig.common.configuration)
    }()

    private let realm: RealmInstance
    private let router: CreatePromptRouter
    
    init(realm: RealmInstance, router: CreatePromptRouter) {
        self.realm = realm
        self.router = router
    }
    
    func transform(input: Input) -> Output {
        
        let _user = self.realm
            .fetch(User.self, primaryKey: SyncUser.current!.identity!)
            .unwrap()
        
        let inputIsValid = Observable.combineLatest(input.title, input.body) { (title, body) in
            return title.count > 10 && body.count > 10
        }
        .asDriver(onErrorJustReturn: false)
        
        let _userInputs = Observable.combineLatest(_user, input.title, input.body) { (user: $0, title: $1, body: $2) }
        
        let _createPrompt = input.createPromptTrigger
            .withLatestFrom(_userInputs)
            .map { self.createPrompt(with: $0) }
            .flatMapLatest { (prompt) in
                return self.realm.save(object: prompt)
            }
            .asDriverOnErrorJustComplete()
        
        let dismiss = Driver.of(_createPrompt, input.cancelTrigger)
            .merge()
            .do(onNext: router.toPrompts)
        
        return Output(inputIsValid: inputIsValid,
                      promptSaved: _createPrompt,
                      dismissViewController: dismiss)
    }
    
    private func createPrompt(with inputs: (User, String, String)) -> Prompt {
        return Prompt(id: UUID().uuidString, title: inputs.1, body: inputs.2, user: inputs.0)
    }

}
