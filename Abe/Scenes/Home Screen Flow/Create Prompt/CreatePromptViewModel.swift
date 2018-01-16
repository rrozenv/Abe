
import Foundation
import RxSwift
import RxCocoa
import Action
import RealmSwift

protocol CreatePromptViewModelInputs {
    var title: AnyObserver<String> { get }
    var body: AnyObserver<String> { get }
    var createPromptTrigger: AnyObserver<Void> { get }
    var cancelTrigger: AnyObserver<Void> { get }
    var selectedImage: AnyObserver<ImageRepresentable> { get }
    var addImageTapped: AnyObserver<Void> { get }
    var addWebLinkTappedInput: AnyObserver<Void> { get }
}

protocol CreatePromptViewModelOutputs {
    var inputIsValid: Driver<Bool> { get }
    var dismissViewController: Driver<Void> { get }
    var routeToAddImage: Driver<Void> { get }
    var didAddImage: Driver<ImageRepresentable> { get }
}

protocol CreatePromptViewModelType {
    var inputs: CreatePromptViewModelInputs { get }
    var outputs: CreatePromptViewModelOutputs { get }
}

final class CreatePromptViewModel: CreatePromptViewModelInputs, CreatePromptViewModelOutputs, CreatePromptViewModelType {
    
    let disposeBag = DisposeBag()
    
    var inputs: CreatePromptViewModelInputs { return self }
    let title: AnyObserver<String>
    let body: AnyObserver<String>
    let createPromptTrigger: AnyObserver<Void>
    let cancelTrigger: AnyObserver<Void>
    let addImageTapped: AnyObserver<Void>
    let addWebLinkTappedInput: AnyObserver<Void>
    //Comes from image search vc
    let selectedImage: AnyObserver<ImageRepresentable>
    
    var outputs: CreatePromptViewModelOutputs { return self }
    let inputIsValid: Driver<Bool>
    let dismissViewController: Driver<Void>
    let routeToAddImage: Driver<Void>
    let didAddImage: Driver<ImageRepresentable>
    
    init?(promptService: PromptService,
         router: CreatePromptRouter) {
        
        guard let user = AppController.shared.currentUser.value else {
            NotificationCenter
                .default.post(name: Notification.Name.logout, object: nil)
            return nil
        }
        
        let currentUser = Variable<User>(user)
        
        let _title = PublishSubject<String>()
        let title = _title.asObservable()
        self.title = _title.asObserver()
        
        let _body = PublishSubject<String>()
        let body = _body.asObservable()
        self.body = _body.asObserver()
        
        let _createTapped = PublishSubject<Void>()
        let createTapped = _createTapped.asObservable()
        self.createPromptTrigger = _createTapped.asObserver()
        
        let _cancelTrigger = PublishSubject<Void>()
        let cancelTrigger = _cancelTrigger.asDriverOnErrorJustComplete()
        self.cancelTrigger = _cancelTrigger.asObserver()
        
        let _selectedImage = PublishSubject<ImageRepresentable>()
        self.selectedImage = _selectedImage.asObserver()
        self.didAddImage = _selectedImage.asDriverOnErrorJustComplete()
        
        let _addImageTapped = PublishSubject<Void>()
        let addImageTapped = _addImageTapped.asDriverOnErrorJustComplete()
        
        self.addImageTapped = _addImageTapped.asObserver()
        
        self.routeToAddImage = addImageTapped
            .do(onNext: router.toImageSearch)
        
        let _addWebLinkTappedInput = PublishSubject<Void>()
        let addWebLinkTappedObservable = _addWebLinkTappedInput.asObservable()
        self.addWebLinkTappedInput = _addWebLinkTappedInput.asObserver()
        
        addWebLinkTappedObservable
            .do(onNext: router.toAddWebLink)
            .subscribe()
            .disposed(by: disposeBag)
    
        self.inputIsValid = Observable
            .combineLatest(title, body) { (title, body) in
                return title.count > 10 && body.count > 10
            }
            .startWith(false)
            .asDriver(onErrorJustReturn: false)
        
        let _promptInputs = Observable
            .combineLatest(title, body) { (title: $0, body: $1) }
        
        let _createPrompt = createTapped
            .withLatestFrom(_promptInputs)
            .flatMapLatest {
                return promptService
                    .createPrompt(title: $0.title, body: $0.body, user: currentUser.value)
            }
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        
        self.dismissViewController = Driver.of(_createPrompt, cancelTrigger)
            .merge()
            .do(onNext: router.toPrompts)
        
    }
    
}
