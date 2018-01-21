
import Foundation
import RxSwift
import RxCocoa

protocol GuessReplyAuthorViewModelInputs {
    var viewWillAppearInput: AnyObserver<Void> { get }
    var selectedUserInput: AnyObserver<IndividualContactViewModel> { get }
    var nextButtonTappedInput: AnyObserver<Void> { get }
}

protocol GuessReplyAuthorViewModelOutputs {
    var currentUsersFriends: Driver<[IndividualContactViewModel]> { get }
    var previousAndCurrentUser: Observable<(previous: IndividualContactViewModel, current: IndividualContactViewModel)> { get }
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
    let selectedUserInput: AnyObserver<IndividualContactViewModel>
    let nextButtonTappedInput: AnyObserver<Void>
    
//MARK: - Outputs
    var outputs: GuessReplyAuthorViewModelOutputs { return self }
    let currentUsersFriends: Driver<[IndividualContactViewModel]>
    var previousAndCurrentUser: Observable<(previous: IndividualContactViewModel, current: IndividualContactViewModel)>
    
//MARK: - Init
    init?(reply: PromptReply,
          userService: UserService = UserService(),
          router: RateReplyRoutingLogic) {
        
        guard let user = AppController.shared.currentUser.value else {
            NotificationCenter.default.post(name: Notification.Name.logout, object: nil)
            return nil
        }
        let currentUser = Variable<User>(user)
        
//MARK: - Subjects
        let _viewWillAppearInput = PublishSubject<Void>()
        let _selectedUserInput = PublishSubject<IndividualContactViewModel>()
        let _nextButtonTappedInput = PublishSubject<Void>()
        
//MARK: - Observers
        self.viewWillAppearInput = _viewWillAppearInput.asObserver()
        self.selectedUserInput = _selectedUserInput.asObserver()
        self.nextButtonTappedInput = _nextButtonTappedInput.asObserver()
        
//MARK: - First Level Observables
        let viewWillAppearObservable = _viewWillAppearInput.asObservable()
        let selectedUserObservable = _selectedUserInput.asObservable()
            .startWith(IndividualContactViewModel(isSelected: false, user: User.defualtUser()))
        let nextButtonTappedObservable = _nextButtonTappedInput.asObservable()
        
//MARK: - Outputs
        self.currentUsersFriends = viewWillAppearObservable
            .flatMap { _ in userService.fetchAll() }
            .map { currentUser.value.registeredUsersInContacts(allUsers: $0) }
            .map { createContactViewModelsFor(registeredUsers: $0) }
            .asDriverOnErrorJustComplete()
        
        self.previousAndCurrentUser = Observable
            .zip(selectedUserObservable, selectedUserObservable.skip(1)) {
                (previous: $0, current: $1)
        }
        
//        nextButtonTappedObservable
//            .withLatestFrom(selectedUserObservable)

    }
}

private func createContactViewModelsFor(registeredUsers: [User]) -> [IndividualContactViewModel] {
    return registeredUsers.map {
        return IndividualContactViewModel(isSelected: false, user: $0)
    }
}
