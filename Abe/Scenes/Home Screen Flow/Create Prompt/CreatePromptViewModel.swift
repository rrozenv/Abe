
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
    var selectedImage: AnyObserver<ImageRepresentable?> { get }
    var addImageTapped: AnyObserver<Void> { get }
    var addWebLinkTappedInput: AnyObserver<Void> { get }
}

protocol CreatePromptViewModelOutputs {
    var inputIsValid: Driver<Bool> { get }
    //var dismissViewController: Driver<Void> { get }
    //var routeToAddImage: Driver<Void> { get }
    var didAddImage: Driver<ImageRepresentable?> { get }
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
    let selectedImage: AnyObserver<ImageRepresentable?>
    let addedWeblinkCallbackInput: AnyObserver<WebLinkThumbnail>
    
    var outputs: CreatePromptViewModelOutputs { return self }
    let inputIsValid: Driver<Bool>
    //let dismissViewController: Driver<Void>
    //let routeToAddImage: Driver<Void>
    let didAddImage: Driver<ImageRepresentable?>
    let addedWeblinkCallbackOutput: Driver<WebLinkThumbnail>
    
    init?(promptService: PromptService,
         router: CreatePromptRouter) {
        
        guard let user = AppController.shared.currentUser.value else {
            NotificationCenter
                .default.post(name: Notification.Name.logout, object: nil)
            return nil
        }
        
        let currentUser = Variable<User>(user)
        
        let _title = PublishSubject<String>()
        let _body = PublishSubject<String>()
        let _createTapped = PublishSubject<Void>()
        let _cancelTrigger = PublishSubject<Void>()
        let _selectedImage = PublishSubject<ImageRepresentable?>()
        let _addedWebLink = PublishSubject<WebLinkThumbnail>()
        let _addImageTapped = PublishSubject<Void>()
        let _addWebLinkTappedInput = PublishSubject<Void>()
        
        self.title = _title.asObserver()
        self.body = _body.asObserver()
        self.createPromptTrigger = _createTapped.asObserver()
        self.cancelTrigger = _cancelTrigger.asObserver()
        self.selectedImage = _selectedImage.asObserver()
        self.addedWeblinkCallbackInput = _addedWebLink.asObserver()
        self.addWebLinkTappedInput = _addWebLinkTappedInput.asObserver()
        self.addImageTapped = _addImageTapped.asObserver()
        
        let title = _title.asObservable()
        let body = _body.asObservable()
        let createTapped = _createTapped.asObservable()
        let cancelTrigger = _cancelTrigger.asObservable()
        let addImageTapped = _addImageTapped.asDriverOnErrorJustComplete()
        let selectedImageObservable = _selectedImage.asObservable().startWith(nil)
        let addedWeblinkCallbackInputObservable = _addedWebLink.asObservable()
        let addWebLinkTappedObservable = _addWebLinkTappedInput.asObservable()
       
        let promptInputsObservable = Observable
            .combineLatest(title, body, selectedImageObservable) {
                (title: $0, body: $1, image: $2)
            }
        
        let createdPromptObservable = createTapped
            .withLatestFrom(promptInputsObservable)
            .filter { $0.image != nil }
            .flatMapLatest {
                return promptService
                    .createPrompt(title: $0.title, body: $0.body, imageUrl: $0.image!.webformatURL, user: currentUser.value)
            }
            .mapToVoid()
        
        self.addedWeblinkCallbackOutput = addedWeblinkCallbackInputObservable.asDriverOnErrorJustComplete()
        self.didAddImage = selectedImageObservable.asDriverOnErrorJustComplete()
        
        self.inputIsValid = Observable
            .combineLatest(title, body, selectedImageObservable) { (title, body, image) in
                return (title.count > 10) && (body.count > 10) && (image != nil)
            }
            .startWith(false)
            .asDriver(onErrorJustReturn: false)
        
        addWebLinkTappedObservable
            .do(onNext: router.toAddWebLink)
            .subscribe()
            .disposed(by: disposeBag)
        
        addImageTapped
            .do(onNext: router.toImageSearch)
            .drive()
            .disposed(by: disposeBag)
        
        Observable.of(createdPromptObservable, cancelTrigger)
            .merge()
            .do(onNext: router.toPrompts)
            .subscribe()
            .disposed(by: disposeBag)
        
//        self.dismissViewController = Observable.of(createdPromptObservable, cancelTrigger)
//            .merge()
//            .do(onNext: router.toPrompts)
//            .asDriverOnErrorJustComplete()
//
        //        self.routeToAddImage = addImageTapped
        //            .do(onNext: router.toImageSearch)
        
    }
    
}
