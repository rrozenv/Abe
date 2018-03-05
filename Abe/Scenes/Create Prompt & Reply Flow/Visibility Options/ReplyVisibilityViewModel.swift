
import Foundation
import RxSwift
import RxCocoa
import RealmSwift
import UIKit

protocol ReplyVisibilityViewModelInputs {
    var viewWillAppearInput: AnyObserver<Void> { get }
    var publicButtonTappedInput: AnyObserver<Void> { get }
    var selectedAllContactsTappedInput: AnyObserver<Bool> { get }
    var selectedUserAndIndexPathInput: AnyObserver<(user: IndividualContactViewModel, indexPath: IndexPath)> { get }
    var createButtonTappedInput: AnyObserver<Void> { get }
    var searchTextInput: AnyObserver<String> { get }
    var backButtonTappedInput: AnyObserver<Void> { get }
}

protocol ReplyVisibilityViewModelOutputs {
    var individualContacts: Driver<[IndividualContactViewModel]> { get }
    var publicButtonTapped: Driver<Void> { get }
    var selectAllContacts: Driver<Bool> { get }
    var currentIndividualNumbers: Driver<[String]> { get }
    var latestUserAndIndexPath: Driver<(user: IndividualContactViewModel, indexPath: IndexPath)> { get }
    var errorTracker: Driver<Error> { get }
    var searchTextObservable: Observable<String> { get }
}

protocol ReplyVisibilityViewModelType {
    var inputs: ReplyVisibilityViewModelInputs { get }
    var outputs: ReplyVisibilityViewModelOutputs { get }
}

typealias TableSection = ReplyVisibilityDataSource.Section

final class ReplyVisibilityViewModel: ReplyVisibilityViewModelInputs, ReplyVisibilityViewModelOutputs, ReplyVisibilityViewModelType {
    
    let disposeBag = DisposeBag()
    
//MARK: - Inputs
    var inputs: ReplyVisibilityViewModelInputs { return self }
    let viewWillAppearInput: AnyObserver<Void>
    let publicButtonTappedInput: AnyObserver<Void>
    let selectedAllContactsTappedInput: AnyObserver<Bool>
    let selectedUserAndIndexPathInput: AnyObserver<(user: IndividualContactViewModel, indexPath: IndexPath)>
    let createButtonTappedInput: AnyObserver<Void>
    let searchTextInput: AnyObserver<String>
    let backButtonTappedInput: AnyObserver<Void>

//MARK: - Outputs
    var outputs: ReplyVisibilityViewModelOutputs { return self }
    let individualContacts: Driver<[IndividualContactViewModel]>
    let publicButtonTapped: Driver<Void>
    let selectAllContacts: Driver<Bool>
    let latestUserAndIndexPath: Driver<(user: IndividualContactViewModel, indexPath: IndexPath)>
    let currentIndividualNumbers: Driver<[String]>
    let errorTracker: Driver<Error>
    let searchTextObservable: Observable<String>
    
//MARK: - Init
    init?(replyService: ReplyService = ReplyService(),
          promptService: PromptService = PromptService(),
          userService: UserService = UserService(),
          router: ReplyOptionsRoutingLogic,
          prompt: Prompt,
          savedReplyInput: SavedReplyInput,
          isForReply: Bool) {
        
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
        let _selectedAllContactsTappedInput = PublishSubject<Bool>()
        let _selectedUserAndIndexPathInput = PublishSubject<(user: IndividualContactViewModel, indexPath: IndexPath)>()
        let _createButtonTappedInput = PublishSubject<Void>()
        let _searchTextInput = PublishSubject<String>()
        let _backButtonTappedInput = PublishSubject<Void>()
        
//MARK: - Observers
        self.viewWillAppearInput = _viewWillAppearInput.asObserver()
        self.publicButtonTappedInput = _publicButtonTappedInput.asObserver()
        self.selectedAllContactsTappedInput = _selectedAllContactsTappedInput.asObserver()
        self.selectedUserAndIndexPathInput = _selectedUserAndIndexPathInput.asObserver()
        self.createButtonTappedInput = _createButtonTappedInput.asObserver()
        self.searchTextInput = _searchTextInput.asObserver()
        self.backButtonTappedInput = _backButtonTappedInput.asObserver()
        
//MARK: - First Level Observables
        let viewWillAppearObservable = _viewWillAppearInput.asObservable()
        let publicButtonTappedObservable = _publicButtonTappedInput.asObservable()
        let selectedAllContactsObservable = _selectedAllContactsTappedInput.asObservable()
        let selectedUserAndIndexPathObservable = _selectedUserAndIndexPathInput.asObservable()
        let createButtonTappedObservable = _createButtonTappedInput.asObservable()
        let backButtonTappedObservable = _backButtonTappedInput.asObservable()

//MARK: - Second Level Observables
        let publicVisibilityObservable = publicButtonTappedObservable
            .map { Visibility.all }
        let allContactsVisibilityObservable = selectedAllContactsObservable
            .map { _ in Visibility.individualContacts }
        let individualContactsVisibilityObservable = selectedUserAndIndexPathObservable
            .map { _ in Visibility.individualContacts }
        let currentVisibilityObservable = Observable.of(publicVisibilityObservable, allContactsVisibilityObservable, individualContactsVisibilityObservable)
            .merge()
        
        let registertedUsersInUserContacts = viewWillAppearObservable
            .flatMap { _ in userService.fetchAll() }
            .map { currentUser.value.registeredUsersInContacts(allUsers: $0) }
            .map { createContactViewModelsFor(registeredUsers: $0) }
        
        let shouldClearSelectedNumbersObservable = Observable.of(publicButtonTappedObservable, selectedAllContactsObservable.filter{ !$0 }.mapToVoid()).merge()
            .map { (user: IndividualContactViewModel(isSelected: false, user: User.defualtUser()),
                    indexPath: IndexPath(row: -1, section: TableSection.contacts.rawValue)) }
        
        let shouldSelectAllContactsObservable = selectedAllContactsObservable
            .filter { $0 }
            .map { _ in
                (user: IndividualContactViewModel(isSelected: true, user: User.defualtUser()),
                    indexPath: IndexPath(row: -1, section: TableSection.contacts.rawValue))
            }
        
        let selectedContactNumbersObservable = Observable
            .of(selectedUserAndIndexPathObservable,         shouldClearSelectedNumbersObservable,
                shouldSelectAllContactsObservable).merge()
            .withLatestFrom(registertedUsersInUserContacts, resultSelector: { (contactVm, registeredUsersVm) in
                return (selected: contactVm.user, all: registeredUsersVm)
            })
            .scan([]) { (summary, i) -> [String] in
                if i.selected.user.phoneNumber == "default" && !i.selected.isSelected {
                    return [] }
                if i.selected.user.phoneNumber == "default" && i.selected.isSelected {
                    return i.all.map { $0.user.phoneNumber } }
                var summaryCopy = summary
                if !i.selected.isSelected {
                    summaryCopy.append(i.selected.user.phoneNumber)
                } else {
                    if let index = summaryCopy
                        .index(where: { $0 == i.selected.user.phoneNumber }) {
                        summaryCopy.remove(at: index)
                    }
                }
                return summaryCopy
        }
        .startWith([])
        
        let createWithIndividualContactsVis = createButtonTappedObservable
            .filter { isForReply }
            .withLatestFrom(currentVisibilityObservable)
            .filter { $0 == Visibility.individualContacts }
            .withLatestFrom(selectedContactNumbersObservable)
            .map { updateReply(savedReplyInput.reply, contactNumbers: $0) }
        
        let createWithGeneralVis = createButtonTappedObservable
            .filter { isForReply }
            .withLatestFrom(currentVisibilityObservable)
            .filter { $0 == Visibility.all }
            .map { updateReplyVisibility(savedReplyInput.reply, vis: $0) }
        
        let createPromptWithIndividualContactsVis = createButtonTappedObservable
            .filter { !isForReply }
            .withLatestFrom(currentVisibilityObservable)
            .filter { $0 == Visibility.individualContacts }
            .withLatestFrom(selectedContactNumbersObservable)
            .map { updatePrompt(savedReplyInput.prompt, contactNumbers: $0) }
        
        let createPromptWithGeneralVis = createButtonTappedObservable
            .filter { !isForReply }
            .withLatestFrom(currentVisibilityObservable)
            .filter { $0 == Visibility.all }
            .map { updatePromptVisibility(savedReplyInput.prompt, vis: $0) }
        
//MARK: - Outputs
        self.individualContacts = viewWillAppearObservable
            .flatMap { _ in userService.fetchAll() }
            .map { currentUser.value.registeredUsersInContacts(allUsers: $0) }
            .map { createContactViewModelsFor(registeredUsers: $0) }
            .asDriverOnErrorJustComplete()
        
        self.publicButtonTapped = publicButtonTappedObservable
            .asDriverOnErrorJustComplete()
        
        self.selectAllContacts = selectedAllContactsObservable
            .asDriver(onErrorJustReturn: false)
        
        self.latestUserAndIndexPath = selectedUserAndIndexPathObservable
            .asDriverOnErrorJustComplete()
        
        self.currentIndividualNumbers = selectedContactNumbersObservable
            .asDriver(onErrorJustReturn: [])
        
        self.searchTextObservable = _searchTextInput.asObservable()

//MARK: - Routing
        Observable.merge(createWithIndividualContactsVis,
                         createWithGeneralVis)
            .flatMapLatest { (reply) in
                return replyService.saveReply(reply)
                    .flatMapLatest { replyService.add(reply: $0, to: prompt) }
                    .flatMapLatest { replyService.add(reply: $0.0, to: currentUser.value) }
                    .trackError(errorTracker)
            }
            .do(onNext: { _ in
                NotificationCenter.default.post(.init(name: .reloadCurrentRepliesTab, object: nil))
                //NotificationCenter.default.post(.init(name: .userUpdated, object: nil))
            })
            .mapToVoid()
            .do(onNext: router.toDismissNavVc)
            .subscribe()
            .disposed(by: disposeBag)
        
        Observable.merge(createPromptWithIndividualContactsVis,
                         createPromptWithGeneralVis)
            .flatMapLatest { (prompt) in
                return promptService.save(prompt)
                    .trackError(errorTracker)
            }
            .do(onNext: { _ in
                NotificationCenter.default.post(.init(name: .userUpdated, object: nil))
            })
            .mapToVoid()
            .do(onNext: router.toDismissNavVc)
            .subscribe()
            .disposed(by: disposeBag)
        
        backButtonTappedObservable
            .do(onNext: router.toPreviousVc)
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

private func updateReply(_ reply: PromptReply?, contactNumbers: [String]) -> PromptReply {
    guard let replyCopy = reply else { return PromptReply() }
    let stringObjects = contactNumbers.map { StringObject($0) }
    replyCopy.visibleOnlyToContactNumbers.append(objectsIn: stringObjects)
    replyCopy.visibleOnlyToPhoneNumbers.append(objectsIn: contactNumbers)
    replyCopy.visibility = Visibility.individualContacts.rawValue
    return replyCopy
}

private func updateReplyVisibility(_ reply: PromptReply?, vis: Visibility) -> PromptReply {
    guard reply != nil else { return PromptReply() }
    reply!.visibility = vis.rawValue
    return reply!
}

private func updatePrompt(_ prompt: Prompt, contactNumbers: [String]) -> Prompt {
    let promptCopy = prompt
    let stringObjects = contactNumbers.map { StringObject($0) }
    promptCopy.visibleOnlyToContactNumbers.append(objectsIn: stringObjects)
    promptCopy.visibility = Visibility.individualContacts.rawValue
    return promptCopy
}

private func updatePromptVisibility(_ prompt: Prompt, vis: Visibility) -> Prompt {
    prompt.visibility = vis.rawValue
    return prompt
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

