
import Foundation
import RxSwift
import RxCocoa
import RealmSwift

final class CreatePromptViewModel: CreatePromptViewModelInputs, CreatePromptViewModelOutputs, CreatePromptViewModelType {
    let disposeBag = DisposeBag()

//MARK: - View Controller Inputs
    var inputs: CreatePromptViewModelInputs { return self }
    let titleTextInput: AnyObserver<String>
    let bodyTextInput: AnyObserver<String>
    let createTappedInput: AnyObserver<Void>
    let cancelTappedInput: AnyObserver<Void>
    let addImageTappedInput: AnyObserver<Void>
    let addWebLinkTappedInput: AnyObserver<Void>
    
//MARK: - Delegate Inputs
    let imageDelegateInput: AnyObserver<ImageRepresentable?>
    let weblinkDelegateInput: AnyObserver<WebLinkThumbnail?>

//MARK: - Outputs
    var outputs: CreatePromptViewModelOutputs { return self }
    let inputIsValid: Driver<Bool>
    let imageDelegateOutput: Driver<ImageRepresentable?>
    let weblinkDelegateOutput: Driver<WebLinkThumbnail?>
    
    init?(promptService: PromptService,
         router: CreatePromptRouter) {
        
        guard let user = AppController.shared.currentUser.value else {
            NotificationCenter.default.post(name: Notification.Name.logout, object: nil)
            return nil
        }
        
        let currentUser = Variable<User>(user)

//MARK: - Subjects
        let _titleTextInput = PublishSubject<String>()
        let _bodyTextInput = PublishSubject<String>()
        let _createTappedInput = PublishSubject<Void>()
        let _cancelTappedInput = PublishSubject<Void>()
        let _addImageTappedInput = PublishSubject<Void>()
        let _addWebLinkTappedInput = PublishSubject<Void>()
        
        let _imageDelegateInput = PublishSubject<ImageRepresentable?>()
        let _weblinkDelegateInput = PublishSubject<WebLinkThumbnail?>()

//MARK: - Observers
        self.titleTextInput = _titleTextInput.asObserver()
        self.bodyTextInput = _bodyTextInput.asObserver()
        self.createTappedInput = _createTappedInput.asObserver()
        self.cancelTappedInput = _cancelTappedInput.asObserver()
        self.addWebLinkTappedInput = _addWebLinkTappedInput.asObserver()
        self.addImageTappedInput = _addImageTappedInput.asObserver()
        
        self.imageDelegateInput = _imageDelegateInput.asObserver()
        self.weblinkDelegateInput = _weblinkDelegateInput.asObserver()

//MARK: - First Level Observables
        let titleTextObservable = _titleTextInput.asObservable()
        let bodyTextObservable = _bodyTextInput.asObservable()
        let createTappedObservable = _createTappedInput.asObservable()
        let cancelTappedObservable = _cancelTappedInput.asObservable()
        let addImageTappedObservable = _addImageTappedInput.asDriverOnErrorJustComplete()
        let addWebLinkTappedObservable = _addWebLinkTappedInput.asObservable()
        
        let imageDelegateInputObservable = _imageDelegateInput.asObservable().startWith(nil)
        let weblinkDelegateInputObservable = _weblinkDelegateInput.asObservable().startWith(nil)
        
//MARK: - Second Level Observables
        let promptInputsObservable = Observable
            .combineLatest(titleTextObservable,
                           bodyTextObservable,
                           imageDelegateInputObservable,
                           weblinkDelegateInputObservable) {
                (title: $0, body: $1, image: $2, webLink: $3)
            }
        
        let didCreatePromptObservable = createTappedObservable
            .withLatestFrom(promptInputsObservable)
            .filter { $0.image != nil }
            .flatMapLatest {
                return promptService
                    .createPrompt(title: $0.title, body: $0.body, imageUrl: $0.image!.webformatURL, webLink: $0.webLink, user: currentUser.value)
            }
            .mapToVoid()

//MARK: - Outputs
        self.weblinkDelegateOutput = weblinkDelegateInputObservable.asDriverOnErrorJustComplete()
        self.imageDelegateOutput = imageDelegateInputObservable.asDriverOnErrorJustComplete()
        self.inputIsValid = Observable
            .combineLatest(titleTextObservable, bodyTextObservable, imageDelegateInputObservable) { (titleTextInput, body, image) in
                return (titleTextInput.count > 10) && (body.count > 10) && (image != nil)
            }
            .startWith(false)
            .asDriver(onErrorJustReturn: false)

//MARK: - Routing
        addWebLinkTappedObservable
            .do(onNext: router.toAddWebLink)
            .subscribe()
            .disposed(by: disposeBag)
        
        addImageTappedObservable
            .do(onNext: router.toImageSearch)
            .drive()
            .disposed(by: disposeBag)
        
        Observable.of(didCreatePromptObservable, cancelTappedObservable)
            .merge()
            .do(onNext: router.toPrompts)
            .subscribe()
            .disposed(by: disposeBag)
    }
    
}

protocol CreatePromptViewModelInputs {
    //MARK: - View Controller Inputs
    var titleTextInput: AnyObserver<String> { get }
    var bodyTextInput: AnyObserver<String> { get }
    var createTappedInput: AnyObserver<Void> { get }
    var cancelTappedInput: AnyObserver<Void> { get }
    var addImageTappedInput: AnyObserver<Void> { get }
    var addWebLinkTappedInput: AnyObserver<Void> { get }
    
    //MARK: - Delegate Inputs
    var imageDelegateInput: AnyObserver<ImageRepresentable?> { get }
    var weblinkDelegateInput: AnyObserver<WebLinkThumbnail?> { get }
}

protocol CreatePromptViewModelOutputs {
    var inputIsValid: Driver<Bool> { get }
    var imageDelegateOutput: Driver<ImageRepresentable?> { get }
    var weblinkDelegateOutput: Driver<WebLinkThumbnail?> { get }
}

protocol CreatePromptViewModelType {
    var inputs: CreatePromptViewModelInputs { get }
    var outputs: CreatePromptViewModelOutputs { get }
}
