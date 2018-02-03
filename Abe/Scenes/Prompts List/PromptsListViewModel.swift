
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
    var viewDidLoadInput: AnyObserver<Void> { get }
    var createTappedInput: AnyObserver<Void> { get }
    var promptSelectedInput: AnyObserver<Prompt> { get }
    var tabVisSelectedInput: AnyObserver<Visibility> { get }
}

protocol PromptListViewModelOutputs {
    var contactsOnlyPrompts: Driver<[Prompt]> { get }
    var publicPrompts: Driver<[Prompt]> { get }
    var activityIndicator: Driver<Bool> { get }
    var errorTracker: Driver<Error> { get }
    var promptsChangeSet: Observable<PromptChangeSet> { get }
    var tabVisSelected: Driver<Visibility> { get }
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
    let tabVisSelectedInput: AnyObserver<Visibility>
    
//MARK: - Delegate Inputs
    let filterOptionsInput: AnyObserver<[PromptListFilterOption]?>
    
//MARK: - Outputs
    var outputs: PromptListViewModelOutputs { return self }
    let activityIndicator: Driver<Bool>
    let contactsOnlyPrompts: Driver<[Prompt]>
    let publicPrompts: Driver<[Prompt]>
    let errorTracker: Driver<Error>
    let promptsChangeSet: Observable<PromptChangeSet>
    let tabVisSelected: Driver<Visibility>

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
        let _filterOptionsInput = PublishSubject<[PromptListFilterOption]?>()
        let _tabVisSelectedInput = PublishSubject<Visibility>()
        
//MARK: - Observers
        self.viewDidLoadInput = _viewDidLoadInput.asObserver()
        self.createTappedInput = _createTappedInput.asObserver()
        self.promptSelectedInput = _promptSelectedInput.asObserver()
        self.filterOptionsInput = _filterOptionsInput.asObserver()
        self.tabVisSelectedInput = _tabVisSelectedInput.asObserver()
        
//MARK: - First Level Observables
        let viewDidLoadObservable = _viewDidLoadInput.asObservable()
        let createTappedObservable = _createTappedInput.asObservable()
        let selectedPromptObservable = _promptSelectedInput.asObservable()
        let tabVisSelectedObservable = _tabVisSelectedInput.asObservable()
        //let filterOptionsObservable = _filterOptionsInput.asObservable().startWith(nil)
        
//MARK: - Outputs
        self.tabVisSelected = tabVisSelectedObservable.asDriver(onErrorJustReturn: .all)
        self.publicPrompts = Observable
            .of(viewDidLoadObservable.map { Visibility.all },
                tabVisSelectedObservable.filter { $0 == Visibility.all })
            .merge()
            .map { NSPredicate(format: "visibility = %@", $0.rawValue) }
            .flatMapLatest {
                promptService
                    .fetchPromptsWith(predicate: $0)
                    .trackActivity(activityIndicator)
                    .trackError(errorTracker)
            }
            .asDriver(onErrorJustReturn: [])

        self.contactsOnlyPrompts =  tabVisSelectedObservable
            .filter { $0 == Visibility.individualContacts }
            .map { [NSPredicate(format: "visibility = %@", $0.rawValue), NSPredicate(format: "ANY visibleOnlyToContactNumbers = %@", StringObject(currentUser.value.phoneNumber))] }
            .map { NSCompoundPredicate(andPredicateWithSubpredicates: $0) }
            .flatMapLatest {
                promptService
                    .fetchPromptsWith(predicate: $0)
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


