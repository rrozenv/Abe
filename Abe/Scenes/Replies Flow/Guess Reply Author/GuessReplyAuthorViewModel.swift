
import Foundation
import RxSwift
import RxCocoa

protocol GuessReplyAuthorViewModelInputs {
    var viewWillAppearInput: AnyObserver<Void> { get }
    var selectedIndexPathInput: AnyObserver<IndexPath> { get }
    var selectedUserViewModelInput: AnyObserver<IndividualContactViewModel> { get }
    var nextButtonTappedInput: AnyObserver<Void> { get }
    var searchTextInput: AnyObserver<String> { get }
    var searchCancelTappedInput: AnyObserver<Void> { get }
}

protocol GuessReplyAuthorViewModelOutputs {
    var allUsersFriends: Driver<[IndividualContactViewModel]> { get }
    //var filteredUsersFriends: Driver<[IndividualContactViewModel]> { get }
    var previousAndCurrentIndexPath: Observable<(previous: IndexPath, current: IndexPath)> { get }
    var nextButtonIsEnabled: Driver<Bool> { get }
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
    let searchCancelTappedInput: AnyObserver<Void>
    
//MARK: - Outputs
    var outputs: GuessReplyAuthorViewModelOutputs { return self }
    let allUsersFriends: Driver<[IndividualContactViewModel]>
    //let filteredUsersFriends: Driver<[IndividualContactViewModel]>
    let previousAndCurrentIndexPath: Observable<(previous: IndexPath, current: IndexPath)>
    let nextButtonIsEnabled: Driver<Bool>
    
//MARK: - Init
    init?(reply: PromptReply,
          ratingScoreValue: Int,
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
        let _searchCancelTappedInput = PublishSubject<Void>()
        
//MARK: - Observers
        self.viewWillAppearInput = _viewWillAppearInput.asObserver()
        self.selectedIndexPathInput = _selectedIndexPathInput.asObserver()
        self.selectedUserViewModelInput = _selectedUserViewModelInput.asObserver()
        self.nextButtonTappedInput = _nextButtonTappedInput.asObserver()
        self.searchTextInput = _searchTextInput.asObserver()
        self.searchCancelTappedInput = _searchCancelTappedInput.asObserver()
        
//MARK: - First Level Observables
        let viewWillAppearObservable = _viewWillAppearInput.asObservable()
        let selectedIndexObservable = _selectedIndexPathInput.asObservable()
            .startWith(IndexPath(row: -1, section: 0))
        let selectedUserViewModelObservable = _selectedUserViewModelInput.asObservable()
            .startWith(IndividualContactViewModel(isSelected: false, user: User.defualtUser()))
        let nextButtonTappedObservable = _nextButtonTappedInput.asObservable()
        let searchTextObservable = _searchTextInput.asObservable()
        let searchCancelTappedObservable = _searchCancelTappedInput.asObservable()

//MARK: - Second Level Observables
        let currentUsersFriendsObservable = viewWillAppearObservable
            .flatMap { _ in userService.fetchAll() }
            .map { currentUser.value.registeredUsersInContacts(allUsers: $0) }
            .map { createContactViewModelsFor(registeredUsers: $0) }
        let filteredUserFriendsObservable = searchTextObservable
            .withLatestFrom(currentUsersFriendsObservable, resultSelector: { (searchText, friends) in
                return friends.filter { $0.user.name.contains(searchText) }
            })
        let resetUsersFriendsWhenCancelTappedObservable =  searchCancelTappedObservable
            .withLatestFrom(currentUsersFriendsObservable)
        
//MARK: - Outputs
        self.allUsersFriends = Observable.of(currentUsersFriendsObservable,
                                             filteredUserFriendsObservable,
                                             resetUsersFriendsWhenCancelTappedObservable).merge()
            .asDriverOnErrorJustComplete()
        
//        self.filteredUsersFriends = searchTextObservable
//            .withLatestFrom(currentUsersFriendsObservable, resultSelector: { (searchText, friends) in
//                return friends.filter { $0.user.name.contains(searchText) }
//            })
//            .asDriverOnErrorJustComplete()
        
        self.previousAndCurrentIndexPath = Observable
            .zip(selectedIndexObservable, selectedIndexObservable.skip(1)) {
                (previous: $0, current: $1)
        }
        
        self.nextButtonIsEnabled = selectedIndexObservable
            .skip(1)
            .map { _ in true }
            .asDriverOnErrorJustComplete()
        
//MARK: - Routing
        nextButtonTappedObservable
            .withLatestFrom(selectedUserViewModelObservable)
            .do(onNext: { router.toInputWagerWith(selectedUser: $0.user, ratingScoreValue: ratingScoreValue, reply: reply) })
            .subscribe()
            .disposed(by: disposeBag)

    }
}

private func createContactViewModelsFor(registeredUsers: [User]) -> [IndividualContactViewModel] {
    return registeredUsers.map {
        return IndividualContactViewModel(isSelected: false, user: $0)
    }
}
