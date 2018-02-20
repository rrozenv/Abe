
import Foundation
import RxSwift
import RxCocoa

protocol GuessReplyAuthorViewModelInputs {
    var viewWillAppearInput: AnyObserver<Void> { get }
    var selectedIndexPathInput: AnyObserver<IndexPath> { get }
    var selectedUserViewModelInput: AnyObserver<IndividualContactViewModel> { get }
    var nextButtonTappedInput: AnyObserver<Void> { get }
    var searchTextInput: AnyObserver<String> { get }
    var backButtonTappedInput: AnyObserver<Void> { get }
}

protocol GuessReplyAuthorViewModelOutputs {
    var allUsersFriends: Driver<[IndividualContactViewModel]> { get }
    var previousAndCurrentSelectedUser: Observable<(previous: IndividualContactViewModel, current: IndividualContactViewModel)> { get }
    var nextButtonIsEnabled: Driver<Bool> { get }
    var searchTextObservable: Observable<String> { get }
    var currentPageIndicator: Driver<Int> { get }
}

protocol GuessReplyAuthorViewModelType {
    var inputs: GuessReplyAuthorViewModelInputs { get }
    var outputs: GuessReplyAuthorViewModelOutputs { get }
}

final class GuessReplyAuthorViewModel: GuessReplyAuthorViewModelInputs, GuessReplyAuthorViewModelOutputs, GuessReplyAuthorViewModelType {
  
    let disposeBag = DisposeBag()
    
//MARK: - Inputs
    var inputs: GuessReplyAuthorViewModelInputs { return self }
    let viewWillAppearInput: AnyObserver<Void>
    let selectedIndexPathInput: AnyObserver<IndexPath>
    let selectedUserViewModelInput: AnyObserver<IndividualContactViewModel>
    let nextButtonTappedInput: AnyObserver<Void>
    let searchTextInput: AnyObserver<String>
    let backButtonTappedInput: AnyObserver<Void>
    
//MARK: - Outputs
    var outputs: GuessReplyAuthorViewModelOutputs { return self }
    let allUsersFriends: Driver<[IndividualContactViewModel]>
    let previousAndCurrentSelectedUser: Observable<(previous: IndividualContactViewModel, current: IndividualContactViewModel)>
    let nextButtonIsEnabled: Driver<Bool>
    let searchTextObservable: Observable<String>
    let currentPageIndicator: Driver<Int>
    
//MARK: - Init
    init?(reply: PromptReply,
          replyScore: ReplyScore,
          userService: UserService = UserService(),
          router: GuessReplyAuthorRoutingLogic) {
        
        guard let user = AppController.shared.currentUser.value else {
            NotificationCenter.default.post(name: Notification.Name.logout, object: nil)
            return nil
        }
        let currentUser = Variable<User>(user)
        
//MARK: - Subjects
        let _viewWillAppearInput = PublishSubject<Void>()
        let _selectedIndexPathInput = PublishSubject<IndexPath>()
        let _selectedUserViewModelInput = PublishSubject<IndividualContactViewModel>()
        let _nextButtonTappedInput = PublishSubject<Void>()
        let _searchTextInput = PublishSubject<String>()
        let _backButtonTappedInput = PublishSubject<Void>()
        
//MARK: - Observers
        self.viewWillAppearInput = _viewWillAppearInput.asObserver()
        self.selectedIndexPathInput = _selectedIndexPathInput.asObserver()
        self.selectedUserViewModelInput = _selectedUserViewModelInput.asObserver()
        self.nextButtonTappedInput = _nextButtonTappedInput.asObserver()
        self.searchTextInput = _searchTextInput.asObserver()
        self.backButtonTappedInput = _backButtonTappedInput.asObserver()
        
//MARK: - First Level Observables
        let selectedIndexObservable = _selectedIndexPathInput.asObservable()
            .startWith(IndexPath(row: -1, section: 0))
        let selectedUserViewModelObservable = _selectedUserViewModelInput.asObservable()
            .startWith(IndividualContactViewModel(isSelected: false, user: User.defualtUser()))
        let nextButtonTappedObservable = _nextButtonTappedInput.asObservable()
        let backButtonTappedObservable = _backButtonTappedInput.asObservable()
        self.searchTextObservable = _searchTextInput.asObservable()

//MARK: - Second Level Observables
        let allUsersFriendsObservable = userService.fetchAll()
            .map { currentUser.value.registeredUsersInContacts(allUsers: $0) }
            .map { createContactViewModelsFor(registeredUsers: $0) }
        
//MARK: - Outputs
        self.allUsersFriends = allUsersFriendsObservable.asDriverOnErrorJustComplete()
        self.previousAndCurrentSelectedUser = Observable
            .zip(selectedUserViewModelObservable, selectedUserViewModelObservable.skip(1)) {
                (previous: $0, current: $1)
            }
        self.nextButtonIsEnabled = selectedIndexObservable
            .skip(1)
            .map { _ in true }
            .asDriverOnErrorJustComplete()
        
        self.currentPageIndicator = Driver.of(1)
        
//MARK: - Routing
        nextButtonTappedObservable
            .withLatestFrom(selectedUserViewModelObservable)
            .do(onNext: { router.toInputWagerWith(selectedUser: $0.user, replyScore: replyScore, reply: reply) })
            .subscribe()
            .disposed(by: disposeBag)
        
        backButtonTappedObservable
            .do(onNext: router.toPreviousNavViewController)
            .subscribe()
            .disposed(by: disposeBag)
    }
}

private func createContactViewModelsFor(registeredUsers: [User]) -> [IndividualContactViewModel] {
    let users = Set<User>(registeredUsers).sorted { $0.name < $1.name }
    return users.map {
        return IndividualContactViewModel(isSelected: false, user: $0)
    }
}
