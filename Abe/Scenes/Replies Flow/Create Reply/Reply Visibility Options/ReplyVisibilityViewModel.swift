
import Foundation
import RxSwift
import RxCocoa
import RealmSwift
import UIKit

protocol ReplyVisibilityViewModelInputs {
    var viewWillAppearInput: AnyObserver<Void> { get }
    var publicButtonTappedInput: AnyObserver<Void> { get }
    var selectedAllContactsTappedInput: AnyObserver<Void> { get }
    var selectedUserAndIndexPathInput: AnyObserver<(user: IndividualContactViewModel, indexPath: IndexPath)> { get }
    var createButtonTappedInput: AnyObserver<Void> { get }
}

protocol ReplyVisibilityViewModelOutputs {
    var individualContacts: Driver<[IndividualContactViewModel]> { get }
    var publicButtonColor: Driver<UIColor> { get }
    var selectAllContacts: Driver<Void> { get }
    var latestUserAndIndexPath: Driver<(user: IndividualContactViewModel, indexPath: IndexPath)> { get }
    var createButtonEnabled: Observable<Bool> { get }
    var errorTracker: Driver<Error> { get }
}

protocol ReplyVisibilityViewModelType {
    var inputs: ReplyVisibilityViewModelInputs { get }
    var outputs: ReplyVisibilityViewModelOutputs { get }
}

final class ReplyVisibilityViewModel: ReplyVisibilityViewModelInputs, ReplyVisibilityViewModelOutputs, ReplyVisibilityViewModelType {
    
    let disposeBag = DisposeBag()
    
//MARK: - Inputs
    var inputs: ReplyVisibilityViewModelInputs { return self }
    let viewWillAppearInput: AnyObserver<Void>
    let publicButtonTappedInput: AnyObserver<Void>
    let selectedAllContactsTappedInput: AnyObserver<Void>
    let selectedUserAndIndexPathInput: AnyObserver<(user: IndividualContactViewModel, indexPath: IndexPath)>
    let createButtonTappedInput: AnyObserver<Void>

//MARK: - Outputs
    var outputs: ReplyVisibilityViewModelOutputs { return self }
    let individualContacts: Driver<[IndividualContactViewModel]>
    let publicButtonColor: Driver<UIColor>
    let selectAllContacts: Driver<Void>
    let latestUserAndIndexPath: Driver<(user: IndividualContactViewModel, indexPath: IndexPath)>
    let createButtonEnabled: Observable<Bool>
    let errorTracker: Driver<Error>

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
        let errorTracker = ErrorTracker()
        self.errorTracker = errorTracker.asDriver()
        
//MARK: - Subjects
        let _viewWillAppearInput = PublishSubject<Void>()
        let _publicButtonTappedInput = PublishSubject<Void>()
        let _selectedAllContactsTappedInput = PublishSubject<Void>()
        let _selectedUserAndIndexPathInput = PublishSubject<(user: IndividualContactViewModel, indexPath: IndexPath)>()
        let _createButtonTappedInput = PublishSubject<Void>()
        
//MARK: - Observers
        self.viewWillAppearInput = _viewWillAppearInput.asObserver()
        self.publicButtonTappedInput = _publicButtonTappedInput.asObserver()
        self.selectedAllContactsTappedInput = _selectedAllContactsTappedInput.asObserver()
        self.selectedUserAndIndexPathInput = _selectedUserAndIndexPathInput.asObserver()
        self.createButtonTappedInput = _createButtonTappedInput.asObserver()
        
//MARK: - First Level Observables
        let viewWillAppearObservable = _viewWillAppearInput.asObservable()
        let publicButtonTappedObservable = _publicButtonTappedInput.asObservable()
        let selectedAllContactsObservable = _selectedAllContactsTappedInput.asObservable()
        let selectedUserAndIndexPathObservable = _selectedUserAndIndexPathInput.asObservable()
        let createButtonTappedObservable = _createButtonTappedInput.asObservable()

//MARK: - Second Level Observables
        let publicVisibilityObservable = publicButtonTappedObservable
            .map { Visibility.all }
        let allContactsVisibilityObservable = selectedAllContactsObservable
            .map { Visibility.contacts }
        let individualContactsVisibilityObservable = selectedUserAndIndexPathObservable
            .map { _ in Visibility.individualContacts }
        let currentVisibilityObservable = Observable.of(publicVisibilityObservable, allContactsVisibilityObservable, individualContactsVisibilityObservable)
            .merge()
        
        let shouldClearSelectedNumbersObservable = publicButtonTappedObservable
            .map { (user: IndividualContactViewModel(isSelected: false, user: User.defualtUser()),
                    indexPath: IndexPath(row: -1, section: 0)) }
        
        let selectedContactNumbersObservable = Observable.of(selectedUserAndIndexPathObservable, shouldClearSelectedNumbersObservable).merge()
            .map { $0.user }
            .scan([]) { (summary, contactViewModel) -> [String] in
                guard contactViewModel.user.phoneNumber != "default" else { return [] }
                var summaryCopy = summary
                if !contactViewModel.isSelected {
                    summaryCopy.append(contactViewModel.user.phoneNumber)
                } else {
                    if let index = summaryCopy
                        .index(where: { $0 == contactViewModel.user.phoneNumber }) {
                        summaryCopy.remove(at: index)
                    }
                }
                return summaryCopy
        }
        .startWith([])
        
        let createWithIndividualContactsVis = createButtonTappedObservable
            .withLatestFrom(currentVisibilityObservable)
            .filter { $0 == Visibility.individualContacts }
            .flatMap { _ in selectedContactNumbersObservable }
            .map { updateReply(savedReplyInput.reply, contactNumbere: $0) }
        let createWithGeneralVis = createButtonTappedObservable
            .withLatestFrom(currentVisibilityObservable)
            .filter { $0 != Visibility.individualContacts }
            .map { updateReplyVisibility(savedReplyInput.reply, vis: $0) }
        
//MARK: - Outputs
        self.individualContacts = viewWillAppearObservable
            .flatMap { _ in userService.fetchAll() }
            .map { currentUser.value.registeredUsersInContacts(allUsers: $0) }
            .map { createContactViewModelsFor(registeredUsers: $0) }
            .asDriverOnErrorJustComplete()
        
        self.publicButtonColor = publicButtonTappedObservable
            .map { UIColor.green }
            .asDriver(onErrorJustReturn: UIColor.green)
        
        self.selectAllContacts = selectedAllContactsObservable
            .asDriver(onErrorJustReturn: ())
        
        self.latestUserAndIndexPath = selectedUserAndIndexPathObservable
            .asDriverOnErrorJustComplete()
        
        self.createButtonEnabled = currentVisibilityObservable
            .withLatestFrom(selectedContactNumbersObservable) { (vis, selectedContacts) in
                switch vis {
                case .all, .contacts:
                    return true
                case .individualContacts:
                    return selectedContacts.isEmpty ? false : true
                default: return false
                }
        }

//MARK: - Routing
        Observable.merge(createWithIndividualContactsVis, createWithGeneralVis)
            .flatMapLatest { (reply) in
                return replyService.saveReply(reply)
                    .flatMapLatest { replyService.add(reply: $0, to: prompt) }
                    .flatMapLatest { replyService.add(reply: $0.0, to: currentUser.value) }
                    .trackError(errorTracker)
            }
            .do(onNext: { _ in
                NotificationCenter.default.post(.init(name: .userUpdated, object: nil))
            })
            .mapToVoid()
            .do(onNext: router.toPromptDetail)
            .subscribe()
            .disposed(by: disposeBag)
    
    }
    
}

private func createContactViewModelsFor(registeredUsers: [User]) -> [IndividualContactViewModel] {
    return registeredUsers.map {
        return IndividualContactViewModel(isSelected: false, user: $0)
    }
}

private func updateReply(_ reply: PromptReply, contactNumbere: [String]) -> PromptReply {
    let replyCopy = reply
    replyCopy.visibleOnlyToPhoneNumbers.append(objectsIn: contactNumbere)
    replyCopy.visibility = Visibility.individualContacts.rawValue
    return replyCopy
}

private func updateReplyVisibility(_ reply: PromptReply, vis: Visibility) -> PromptReply {
    reply.visibility = vis.rawValue
    return reply
}

struct IndividualContactViewModel {
    var isSelected: Bool
    var user: User
}

extension IndividualContactViewModel: Equatable {
    static func ==(lhs: IndividualContactViewModel, rhs: IndividualContactViewModel) -> Bool {
        return lhs.user.id == rhs.user.id
    }
}

struct VisibilityCellViewModel {
    var isSelected: Bool
    var visibility: Visibility
}

