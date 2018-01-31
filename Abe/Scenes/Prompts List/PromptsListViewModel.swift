
import Foundation
import RxSwift
import RxCocoa
import RealmSwift
import RxRealm

protocol PromptListViewModelInputs {
    var viewDidLoadInput: AnyObserver<Void> { get }
    var createTappedInput: AnyObserver<Void> { get }
    var promptSelectedInput: AnyObserver<Prompt> { get }
}

protocol PromptListViewModelOutputs {
    var contactsOnlyPrompts: Driver<[Prompt]> { get }
    var publicPrompts: Driver<[Prompt]> { get }
    var activityIndicator: Driver<Bool> { get }
    var errorTracker: Driver<Error> { get }
    var promptsChangeSet: Observable<PromptChangeSet> { get }
}

protocol PromptListViewModelType {
    var inputs: PromptListViewModelInputs { get }
    var outputs: PromptListViewModelOutputs { get }
}

final class PromptListViewModel: PromptListViewModelType, PromptListViewModelInputs, PromptListViewModelOutputs {
    
    let disposeBag = DisposeBag()
    
//MARK: - Inputs
    var inputs: PromptListViewModelInputs { return self }
    let viewDidLoadInput: AnyObserver<Void>
    let createTappedInput: AnyObserver<Void>
    let promptSelectedInput: AnyObserver<Prompt>
    
//MARK: - Outputs
    var outputs: PromptListViewModelOutputs { return self }
    let activityIndicator: Driver<Bool>
    let contactsOnlyPrompts: Driver<[Prompt]>
    let publicPrompts: Driver<[Prompt]>
    let errorTracker: Driver<Error>
    let promptsChangeSet: Observable<PromptChangeSet>

//MARK: - Init
    init?(promptService: PromptService = PromptService(),
         router: PromptsRoutingLogic) {
        
        guard let user = AppController.shared.currentUser.value else {
            NotificationCenter.default.post(name: Notification.Name.logout, object: nil)
            return nil
        }
        
        let currentUser = Variable<User>(user)
        let activityIndicator = ActivityIndicator()
        let errorTracker = ErrorTracker()
        self.activityIndicator = activityIndicator.asDriver()
        self.errorTracker = errorTracker.asDriver()
        
//MARK: - Subjects
        let _viewDidLoadInput = PublishSubject<Void>()
        let _createTappedInput = PublishSubject<Void>()
        let _promptSelectedInput = PublishSubject<Prompt>()
        
//MARK: - Observers
        self.viewDidLoadInput = _viewDidLoadInput.asObserver()
        self.createTappedInput = _createTappedInput.asObserver()
        self.promptSelectedInput = _promptSelectedInput.asObserver()
        
//MARK: - First Level Observables
        let viewDidLoadObservable = _viewDidLoadInput.asObservable()
        let createTappedObservable = _createTappedInput.asObservable()
        let selectedPromptObservable = _promptSelectedInput.asObservable()
        
//MARK: - Outputs
        let contactsVisOnly = NSPredicate(format: "visibility = %@", "contacts")
        self.contactsOnlyPrompts = viewDidLoadObservable
            .flatMapLatest {
                promptService
                    .fetchPromptsWith(predicate: contactsVisOnly)
                    .trackActivity(activityIndicator)
                    .trackError(errorTracker)
             }
            .map { $0.filter { $0.isViewableBy(currentUser: currentUser.value) } }
            .asDriver(onErrorJustReturn: [])
        
        //let publicVisOnly = NSPredicate(format: "visibility = %@", "all")
        self.publicPrompts = viewDidLoadObservable
            .flatMapLatest {
                promptService
                    .fetchAll()
                    .trackActivity(activityIndicator)
                    .trackError(errorTracker)
            }
            .asDriver(onErrorJustReturn: [])
        
        self.promptsChangeSet = viewDidLoadObservable
            .flatMapLatest {
                promptService.changeSet()
                    .trackError(errorTracker)
            }
        
//MARK: - Routing
        createTappedObservable
            .do(onNext: router.toCreatePrompt)
            .subscribe()
            .disposed(by: disposeBag)
        
        selectedPromptObservable
            .do(onNext: router.toPrompt)
            .subscribe()
            .disposed(by: disposeBag)
    }
    
}

typealias PromptChangeSet = (AnyRealmCollection<Prompt>, RealmChangeset?)
//
//final class PromptsListViewModel: ViewModelType {
//
//    struct Input {
//        let createPostTrigger: Driver<Void>
//        let selection: Driver<Prompt>
//    }
//
//    struct Output {
//        let fetching: Driver<Bool>
//        let posts: Observable<PromptChangeSet>
//        let createPrompt: Driver<Void>
//        let selectedPrompt: Driver<Prompt>
//        let error: Driver<Error>
//    }
//
//    private let realm: RealmInstance
//    private let router: PromptsRoutingLogic
//    private let promptService = PromptService()
//
//    init(realm: RealmInstance, router: PromptsRouter) {
//        self.realm = realm
//        self.router = router
//    }
//
//    func transform(input: Input) -> Output {
//        let activityIndicator = ActivityIndicator()
//        let errorTracker = ErrorTracker()
//        let fetching = activityIndicator.asDriver()
//        let errors = errorTracker.asDriver()
//
//
//        //        let contactsOnlyPrompts = self.promptService
//        //            .fetchPromptsWith(predicate: predicate)
//        //            .map { $0.filter { $0.isViewableBy(currentUser: <#T##User#>)} }
//
//        let prompts = self.realm
//            .fetchAll(Prompt.self)
//            .trackError(errorTracker)
//            .trackActivity(activityIndicator)
//
//        let selectedPrompt = input.selection
//            .do(onNext: router.toPrompt)
//
//        let createPrompt = input.createPostTrigger
//            .do(onNext: router.toCreatePrompt)
//
//        return Output(fetching: fetching,
//                      posts: prompts,
//                      createPrompt: createPrompt,
//                      selectedPrompt: selectedPrompt,
//                      error: errors)
//    }
//
//}


