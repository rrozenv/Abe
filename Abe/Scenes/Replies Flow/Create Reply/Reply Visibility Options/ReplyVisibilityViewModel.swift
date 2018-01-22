
import Foundation
import RxSwift
import RxCocoa
import RealmSwift

protocol ReplyVisibilityViewModelInputs {
    var viewWillAppear: AnyObserver<Void> { get }
    var createTrigger: AnyObserver<Void> { get }
    var generalVisibilitySelected: AnyObserver<Visibility> { get }
    var selectedContact: AnyObserver<(User?, Bool?, Bool)> { get }
}

protocol ReplyVisibilityViewModelOutputs {
    var generalVisibilityOptions: Driver<[VisibilityCellViewModel]> { get }
    var individualContacts: Driver<[IndividualContactViewModel]> { get }
    var didCreateReply: Driver<Void> { get }
    var currentlySelectedIndividualContacts: Observable<[String]> { get }
    var latestSelectedGeneralVisibility: Observable<Visibility> { get }
    var savedContactIndexPaths: Variable<[IndividualContactViewModel]> { get }
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
    let viewWillAppear: AnyObserver<Void>
    let createTrigger: AnyObserver<Void>
    let generalVisibilitySelected: AnyObserver<Visibility>
    let selectedContact: AnyObserver<(User?, Bool?, Bool)>

//MARK: - Outputs
    var outputs: ReplyVisibilityViewModelOutputs { return self }
    let generalVisibilityOptions: Driver<[VisibilityCellViewModel]>
    let latestSelectedGeneralVisibility: Observable<Visibility>
    let individualContacts: Driver<[IndividualContactViewModel]>
    let didCreateReply: Driver<Void>
    let currentlySelectedIndividualContacts: Observable<[String]>
    let createButtonEnabled: Observable<Bool>
    let errorTracker: Driver<Error>
    
    let savedContactIndexPaths = Variable<[IndividualContactViewModel]>([])

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
        
//MARK: - View Will Appear
        let _viewWillAppear = PublishSubject<Void>()
        let viewWillAppearObservable = _viewWillAppear.asObservable()
        self.viewWillAppear = _viewWillAppear.asObserver()
        
//MARK: - General Visibility Options
        let _options: [VisibilityCellViewModel] = [Visibility.all, Visibility.contacts].enumerated().map {
            VisibilityCellViewModel(isSelected: $0.offset == 0 ? true : false, visibility: $0.element)
        }
        self.generalVisibilityOptions = Driver.of(_options)
        
        let _generalVisSelected = PublishSubject<Visibility>()
        self.latestSelectedGeneralVisibility = _generalVisSelected
            .asObservable()
            //.distinctUntilChanged()
            .startWith(.all)
        
        self.generalVisibilitySelected = _generalVisSelected.asObserver()

//MARK: - Individual Contacts
        self.individualContacts = viewWillAppearObservable
            .flatMap { _ in userService.fetchAll() }
            .map { currentUser.value.registeredUsersInContacts(allUsers: $0) }
            .map { createContactViewModelsFor(registeredUsers: $0) }
            .asDriverOnErrorJustComplete()

//MARK: - Selected Contact
        let _selectedContact = PublishSubject<(User?, Bool?, Bool)>()
        let selectedContactObservable = _selectedContact.asObservable()
        self.selectedContact = _selectedContact.asObserver()
        
        let _currentlySelectedIndividualContacts = selectedContactObservable
            .scan([]) { (summary, inputs) -> [String] in
                let removeAll = inputs.2
                guard let shouldAppendUser = inputs.1, let user = inputs.0, !removeAll else {
                    return [String]() }
                var summaryCopy = summary
                if shouldAppendUser {
                    summaryCopy.append(user.phoneNumber)
                } else {
                    if let index = summaryCopy.index(where: { $0 == user.phoneNumber }) {
                        summaryCopy.remove(at: index)
                    }
                }
                return summaryCopy
            }
        
        self.currentlySelectedIndividualContacts = _currentlySelectedIndividualContacts
        
        self.createButtonEnabled = latestSelectedGeneralVisibility
            .withLatestFrom(_currentlySelectedIndividualContacts) { (vis, selectedContacts) in
                switch vis {
                case .all, .contacts:
                    return true
                case .individualContacts:
                    return selectedContacts.isEmpty ? false : true
                default:
                    return false
                }
                //return vis != .individualContacts && !selectedContacts.isEmpty
            }
        
//MARK: - Create Reply Tapped
        let _createReplyTapped = PublishSubject<Void>()
        self.createTrigger = _createReplyTapped.asObserver()
        
        let createReplyWithIndividual = _createReplyTapped.asObservable()
            .debug()
            .withLatestFrom(self.latestSelectedGeneralVisibility)
            .filter {
                $0 == Visibility.individualContacts
            }
            .flatMap { _ in
                _currentlySelectedIndividualContacts
            }
            .map {
                updateReply(savedReplyInput.reply, contactNumbere: $0)
            }
        
        let createReplyWithGeneralVis = _createReplyTapped.asObservable()
            .withLatestFrom(self.latestSelectedGeneralVisibility)
            .filter { $0 != Visibility.individualContacts }
            .map { updateReplyVisibility(savedReplyInput.reply, vis: $0) }
        
        self.didCreateReply = Observable.merge(createReplyWithIndividual, createReplyWithGeneralVis)
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
            .asDriverOnErrorJustComplete()
    
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

