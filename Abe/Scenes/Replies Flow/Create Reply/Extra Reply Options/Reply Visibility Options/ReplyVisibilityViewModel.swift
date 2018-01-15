
import Foundation
import RxSwift
import RxCocoa

protocol ReplyVisibilityViewModelInputs {
    var createTrigger: AnyObserver<Void> { get }
    var generalVisibilitySelected: AnyObserver<Visibility> { get }
    var selectedIndividualContacts: AnyObserver<[User]> { get }
}

protocol ReplyVisibilityViewModelOutputs {
    var generalVisibilityOptions: Driver<[Visibility]> { get }
    var individualContacts: Driver<[User]> { get }
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
    let createTrigger: AnyObserver<Void>
    let generalVisibilitySelected: AnyObserver<Visibility>
    let selectedIndividualContacts: AnyObserver<[User]>
    //let cancelTrigger: AnyObserver<Void>
    
    //MARK: - Outputs
    var outputs: ReplyVisibilityViewModelOutputs { return self }
    let generalVisibilityOptions: Driver<[Visibility]>
    let individualContacts: Driver<[User]>
//    let activityIndicator: Driver<Bool>
//    let errorTracker: Driver<Error>
    let didCreateReply: Driver<Void>
    //let dismissViewController: Observable<Void>
    let currentlySelectedIndividualContacts: Observable<[String]>
    
    //MARK: - Init
    init?(replyService: ReplyService = ReplyService(),
          router: ReplyOptionsRoutingLogic,
          prompt: Prompt,
          savedReplyInput: SavedReplyInput) {
        
        guard let user = AppController.shared.currentUser.value else {
            NotificationCenter
                .default.post(name: Notification.Name.logout, object: nil)
            return nil
        }
        
        let currentUser = Variable<User>(user)
//        let activityIndicator = ActivityIndicator()
//        let errorTracker = ErrorTracker()
//        self.activityIndicator = activityIndicator.asDriver()
//        self.errorTracker = errorTracker.asDriver()
        
//MARK: - General Visibility Options
        let _options: [Visibility] = [.all, .individualContacts, .contacts]
        self.generalVisibilityOptions = Driver.of(_options)
        
        let _generalVisSelected = BehaviorSubject<Visibility>(value: .all)
        let generalVisSelected = _generalVisSelected.asObservable()
        self.generalVisibilitySelected = _generalVisSelected.asObserver()

//MARK: - Individual Contacts
        self.individualContacts = currentUser.asObservable()
            .map { $0.registeredContacts.toArray() }
            .asDriverOnErrorJustComplete()

        let _selectedInvidualContacts = PublishSubject<[User]>()
        let currentSelectedContacts = _selectedInvidualContacts.asObservable()
        self.selectedIndividualContacts = _selectedInvidualContacts.asObserver()
        
        self.currentlySelectedIndividualContacts = currentSelectedContacts
            .map { $0.map { $0.phoneNumber } }
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

