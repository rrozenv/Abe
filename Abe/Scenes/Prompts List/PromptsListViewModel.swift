
import Foundation
import RxSwift
import RxCocoa
import RealmSwift
import RxRealm

typealias PromptChangeSet = (AnyRealmCollection<Prompt>, RealmChangeset?)

final class PromptsListViewModel: ViewModelType {
    
    struct Input {
        let createPostTrigger: Driver<Void>
        let selection: Driver<Prompt>
    }
    
    struct Output {
        let fetching: Driver<Bool>
        let posts: Observable<PromptChangeSet>
        let createPrompt: Driver<Void>
        let selectedPrompt: Driver<Prompt>
       // let saveUserInfo: Driver<Void>
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
        let fetching = activityIndicator.asDriver()
        let errors = errorTracker.asDriver()
        
//        let saveUser = self.realm
//            .query(User.self, with: User.currentUserPredicate, sortDescriptors: [])
//            .map { $0.first }
//            .map { Application.shared.currentUser = $0 }
//            .mapToVoid()
//            .asDriverOnErrorJustComplete()
        
//        let prompts = self.realm.queryAll(Prompt.self)
//            .trackActivity(activityIndicator)
//            .trackError(errorTracker)
//            .asDriverOnErrorJustComplete()
        
        let prompts = self.realm
            .fetch(Prompt.self)
            .trackError(errorTracker)
            .trackActivity(activityIndicator)
        
        let selectedPrompt = input.selection.do(onNext: router.toPrompt)

        let createPrompt = input.createPostTrigger
            .do(onNext: router.toCreatePrompt)
        
        return Output(fetching: fetching,
                      posts: prompts,
                      createPrompt: createPrompt,
                      selectedPrompt: selectedPrompt,
                      error: errors)
    }
    
}


