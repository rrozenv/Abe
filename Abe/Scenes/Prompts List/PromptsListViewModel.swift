
import Foundation
import RxSwift
import RxCocoa
import RealmSwift
import RxRealmDataSources

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}

final class PromptsListViewModel: ViewModelType {
    
    struct Input {
        let createPostTrigger: Driver<Void>
        let selection: Driver<Prompt>
    }
    
    struct Output {
        let fetching: Driver<Bool>
        let posts: Driver<Results<Prompt>>
        let createPrompt: Driver<Void>
        let selectedPrompt: Driver<Prompt>
        let error: Driver<Error>
    }
    
    private let realm: RealmInstance
    private let router: PromptsRoutingLogic
    
    init(realm: RealmInstance, router: PromptsRouter) {
        self.realm = realm
        self.router = router
    }
    
    func transform(input: Input) -> Output {
        let activityIndicator = ActivityIndicator()
        let errorTracker = ErrorTracker()
        
        let prompts = self.realm.queryAll(Prompt.self)
            .trackActivity(activityIndicator)
            .trackError(errorTracker)
            .asDriverOnErrorJustComplete()
        
        let fetching = activityIndicator.asDriver()
        let errors = errorTracker.asDriver()
        
        let selectedPrompt = input.selection.do(onNext: router.toPrompt)

        let createPrompt = input.createPostTrigger
            .do(onNext: router.toCreatePrompt)
        
        return Output(fetching: fetching, posts: prompts, createPrompt: createPrompt, selectedPrompt: selectedPrompt, error: errors)
    }
}


