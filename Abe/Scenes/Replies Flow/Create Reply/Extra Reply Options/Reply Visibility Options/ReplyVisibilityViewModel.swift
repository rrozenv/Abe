
import Foundation
import RxSwift
import RxCocoa
import RealmSwift

//        let activityIndicator = ActivityIndicator()
//        let errorTracker = ErrorTracker()
//        self.activityIndicator = activityIndicator.asDriver()
//        self.errorTracker = errorTracker.asDriver()

//    let activityIndicator: Driver<Bool>
//    let errorTracker: Driver<Error>
//let dismissViewController: Observable<Void>
    //let cancelTrigger: AnyObserver<Void>
    //let selectedIndividualContacts: AnyObserver<[User]>

protocol ReplyVisibilityViewModelInputs {
    var viewWillAppear: AnyObserver<Void> { get }
    var createTrigger: AnyObserver<Void> { get }
    var generalVisibilitySelected: AnyObserver<Visibility> { get }
    var selectedContact: AnyObserver<(User, Bool)> { get }
}

protocol ReplyVisibilityViewModelOutputs {
    var generalVisibilityOptions: Driver<[VisibilityCellViewModel]> { get }
    var individualContacts: Driver<[IndividualContactViewModel]> { get }
    var didCreateReply: Driver<Void> { get }
    var currentlySelectedIndividualContacts: Observable<[String]> { get }
}

protocol ReplyVisibilityViewModelType {
    var inputs: ReplyVisibilityViewModelInputs { get }
    var outputs: ReplyVisibilityViewModelOutputs { get }
}

final class ReplyVisibilityViewModel: ReplyVisibilityViewModelInputs, ReplyVisibilityViewModelOutputs, ReplyVisibilityViewModelType {
    
    let disposeBag = DisposeBag()
    
//MARK: - Inputs
    var inputs: ReplyVisibilityViewModelInputs { return self }
    let viewWillAppear: AnyObserver<Void>
    let createTrigger: AnyObserver<Void>
    let generalVisibilitySelected: AnyObserver<Visibility>
    let selectedContact: AnyObserver<(User, Bool)>

//MARK: - Outputs
    var outputs: ReplyVisibilityViewModelOutputs { return self }
    let generalVisibilityOptions: Driver<[VisibilityCellViewModel]>
    let individualContacts: Driver<[IndividualContactViewModel]>
    let didCreateReply: Driver<Void>
    let currentlySelectedIndividualContacts: Observable<[String]>

//MARK: - Init
    init?(replyService: ReplyService = ReplyService(),
          userService: UserService = UserService(),
          router: ReplyOptionsRoutingLogic,
          prompt: Prompt,
          savedReplyInput: SavedReplyInput) {
        
        guard let user = AppController.shared.currentUser.value else {
            NotificationCenter
                .default.post(name: Notification.Name.logout, object: nil)
            return nil
        }
        
        let currentUser = Variable<User>(user)
        
//MARK: - View Will Appear
        let _viewWillAppear = PublishSubject<Void>()
        let viewWillAppearObservable = _viewWillAppear.asObservable()
        self.viewWillAppear = _viewWillAppear.asObserver()
        
//MARK: - General Visibility Options
        let _options: [VisibilityCellViewModel] = [Visibility.all, Visibility.contacts].enumerated().map {
            VisibilityCellViewModel(isSelected: $0.offset == 0 ? true : false, visibility: $0.element)
        }
        self.generalVisibilityOptions = Driver.of(_options)
        
        let _generalVisSelected = BehaviorSubject<Visibility>(value: .all)
        let generalVisSelected = _generalVisSelected.asObservable().distinctUntilChanged()
        self.generalVisibilitySelected = _generalVisSelected.asObserver()

//MARK: - Individual Contacts
        self.individualContacts = viewWillAppearObservable
            .flatMap { _ in userService.fetchAll() }
            .map { currentUser.value.registeredUsersInContacts(allUsers: $0) }
            .map { createContactViewModelsFor(registeredUsers: $0) }
            .asDriverOnErrorJustComplete()

//MARK: - Selected Contact
        let _selectedContact = PublishSubject<(User, Bool)>()
        let selectedContactObservable = _selectedContact.asObservable()
        self.selectedContact = _selectedContact.asObserver()
        
        self.currentlySelectedIndividualContacts = selectedContactObservable
            .scan([]) { (summary, user) -> [String] in
                var summaryCopy = summary
                if user.1 == true {
                    summaryCopy.append(user.0.phoneNumber)
                } else {
                    if let index = summaryCopy.index(where: { $0 == user.0.phoneNumber }) {
                        summaryCopy.remove(at: index)
                    }
                }
                return summaryCopy
            }
            .startWith([])
        
//MARK: - Create Reply Tapped
        let _createReplyTapped = PublishSubject<Void>()
        self.createTrigger = _createReplyTapped.asObserver()
        
        let _currentPrompt = Observable.of(prompt)
        let _savedReplyInput = Observable.of(savedReplyInput)
        let _reply =
            Observable.combineLatest(_currentPrompt,
                                     _savedReplyInput,
                                     generalVisSelected,
                                     self.currentlySelectedIndividualContacts) { (prompt, replyInput, visibility, selectedIndividualNumbers) -> PromptReply in
                                        if !selectedIndividualNumbers.isEmpty {
                                           return PromptReply(user: currentUser.value,
                                                        promptId: prompt.id,
                                                        body: replyInput.body,
                                                        visibility: Visibility.individualContacts.rawValue,
                                                        individualContactNumbers: selectedIndividualNumbers)
                                        } else {
                                            return PromptReply(user: currentUser.value,
                                                               promptId: prompt.id,
                                                               body: replyInput.body,
                                                               visibility:
                                                               visibility.rawValue)
                                        }
                                   
        }

        self.didCreateReply = _createReplyTapped.asObservable()
            .withLatestFrom(_reply)
            .flatMapLatest { (reply) in
                return replyService.saveReply(reply)
                    .flatMapLatest { replyService.add(reply: $0, to: prompt) }
                    .flatMapLatest { replyService.add(reply: $0.0, to: currentUser.value) }
            }
            .do(onNext: { _ in
                NotificationCenter.default.post(.init(name: .userUpdated, object: nil))
            })
            .mapToVoid()
            .do(onNext: router.toPromptDetail)
            .asDriverOnErrorJustComplete()
        
    }
    
}

private func createContactViewModelsFor(registeredUsers: [User]) -> [IndividualContactViewModel] {
    return registeredUsers.map {
        return IndividualContactViewModel(isSelected: false, user: $0)
    }
}

struct IndividualContactViewModel {
    var isSelected: Bool
    var user: User
}

struct VisibilityCellViewModel {
    var isSelected: Bool
    var visibility: Visibility
}

