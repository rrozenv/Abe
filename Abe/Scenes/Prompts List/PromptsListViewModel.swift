
import Foundation
import RxSwift
import RxCocoa
import RealmSwift
import RxRealm

enum PromptListFilterOption {
    case friendsOnly
    case categories([String])
}

typealias PromptChangeSet = (AnyRealmCollection<Prompt>, RealmChangeset?)

protocol PromptListViewModelInputs {
    var visWhenViewLoadsInput: AnyObserver<Visibility> { get }
    var promptSelectedInput: AnyObserver<Prompt> { get }
}

protocol PromptListViewModelOutputs {
    var promptsToDisplay: Driver<[Prompt]> { get }
    var selectedPrompt: Driver<Prompt> { get }
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
    let visWhenViewLoadsInput: AnyObserver<Visibility>
    let promptSelectedInput: AnyObserver<Prompt>
    
//MARK: - Delegate Inputs
    let filterOptionsInput: AnyObserver<[PromptListFilterOption]?>
    
//MARK: - Outputs
    var outputs: PromptListViewModelOutputs { return self }
    let activityIndicator: Driver<Bool>
    let promptsToDisplay: Driver<[Prompt]>
    let selectedPrompt: Driver<Prompt>
    let errorTracker: Driver<Error>
    let promptsChangeSet: Observable<PromptChangeSet>

//MARK: - Init
    init?(promptService: PromptService = PromptService()
          //router: PromptsRoutingLogic
          ) {
        
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
        let _visWhenViewLoadsInput = PublishSubject<Visibility>()
        let _promptSelectedInput = PublishSubject<Prompt>()
        let _filterOptionsInput = PublishSubject<[PromptListFilterOption]?>()
        
//MARK: - Observers
        self.visWhenViewLoadsInput = _visWhenViewLoadsInput.asObserver()
        self.promptSelectedInput = _promptSelectedInput.asObserver()
        self.filterOptionsInput = _filterOptionsInput.asObserver()
        
//MARK: - First Level Observables
        let visWhenViewLoadsObservable = _visWhenViewLoadsInput.asObservable()
        let selectedPromptObservable = _promptSelectedInput.asObservable()
        //let filterOptionsObservable = _filterOptionsInput.asObservable().startWith(nil)
        
//MARK: - Outputs
        self.promptsToDisplay = visWhenViewLoadsObservable
            .map { $0.queryPredicateFor(currentUser: currentUser.value) }
            .map { NSCompoundPredicate(andPredicateWithSubpredicates: $0) }
            .flatMapLatest {
                promptService
                    .fetchPromptsWith(predicate: $0)
                    .trackActivity(activityIndicator)
                    .trackError(errorTracker)
            }
            .asDriver(onErrorJustReturn: [])

        self.promptsChangeSet = visWhenViewLoadsObservable
            .map { $0.queryPredicateFor(currentUser: currentUser.value) }
            .map { NSCompoundPredicate(andPredicateWithSubpredicates: $0) }
            .flatMapLatest {
                promptService.changeSetFor(predicate: $0)
                    .trackError(errorTracker)
            }
        
//MARK: - Routing
        self.selectedPrompt = selectedPromptObservable
            .asDriverOnErrorJustComplete()
        
    }
    
}



//let contactsVisOnly = NSPredicate(format: "visibility = %@", "individualContacts")
//let isViewableByCurrentUser = NSPredicate(format: "visibleOnlyToPhoneNumbers.value CONTAINS %@", currentUser.value.phoneNumber)
//let onlyUserFriendPrompts = NSPredicate(format:"user.value.phoneNumber IN %@", currentUser.value.allNumbersFromContacts())
//let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [contactsVisOnly, onlyUserFriendPrompts])
//
//self.contactsOnlyPrompts = viewDidLoadObservable
//    .flatMapLatest {
//        promptService
//            .fetchPromptsWith(predicate: contactsVisOnly)
//            .trackActivity(activityIndicator)
//            .trackError(errorTracker)
//    }
//    .map { $0.filter { $0.isViewableBy(currentUser: currentUser.value) } }
//    .asDriver(onErrorJustReturn: [])
//
//let filteredPrompts = filterOptionsObservable
//    .unwrap()
//    .map { (options) -> [NSPredicate] in
//        return options.flatMap {
//            switch $0 {
//            case .friendsOnly: return isViewableByCurrentUser
//            case .categories(_): return nil
//            }
//        }
//    }
//    .map { NSCompoundPredicate(andPredicateWithSubpredicates: $0) }
//    .flatMapLatest {
//        promptService
//            .fetchPromptsWith(predicate: $0)
//            .trackActivity(activityIndicator)
//            .trackError(errorTracker)
//}


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


