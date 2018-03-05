
import Foundation
import RxSwift
import RxCocoa
import RxOptional

protocol AddWebLinkViewModelInputs {
    var searchTextInput: AnyObserver<String> { get }
    var searchTappedInput: AnyObserver<Void> { get }
    var doneTappedInput: AnyObserver<Void> { get }
    var removeWebLinkTappedInput: AnyObserver<Void> { get }
    var backButtonTappedInput: AnyObserver<Void> { get }
}

protocol AddWebLinkViewModelOutputs {
    var linkThumbnail: Driver<WebLinkThumbnail?> { get }
    var searchTextIsValid: Driver<Bool> { get }
    var activityIndicator: Driver<Bool> { get }
    var errorTracker: Driver<Error> { get }
}

protocol AddWebLinkViewModelType {
    var inputs: AddWebLinkViewModelInputs { get }
    var outputs: AddWebLinkViewModelOutputs { get }
}

final class AddWebLinkViewModel: AddWebLinkViewModelType, AddWebLinkViewModelInputs, AddWebLinkViewModelOutputs {
    
    let disposeBag = DisposeBag()
    
//MARK: - Inputs
    var inputs: AddWebLinkViewModelInputs { return self }
    let searchTextInput: AnyObserver<String>
    let searchTappedInput: AnyObserver<Void>
    let doneTappedInput: AnyObserver<Void>
    let removeWebLinkTappedInput: AnyObserver<Void>
    let backButtonTappedInput: AnyObserver<Void>
    
//MARK: - Outputs
    var outputs: AddWebLinkViewModelOutputs { return self }
    let linkThumbnail: Driver<WebLinkThumbnail?>
    let searchTextIsValid: Driver<Bool>
    let activityIndicator: Driver<Bool>
    let errorTracker: Driver<Error>
    
//MARK: - Init
    init(thumbnailService: WebLinkThumbnailService = WebLinkThumbnailService(),
         router: AddWebLinkRoutingLogic) {
        let activityIndicator = ActivityIndicator()
        let errorTracker = ErrorTracker()
        self.activityIndicator = activityIndicator.asDriver()
        self.errorTracker = errorTracker.asDriver()
        
//MARK: - Subjects
        let _searchTextInput = PublishSubject<String>()
        let _searchTappedInput = PublishSubject<Void>()
        let _doneTappedInput = PublishSubject<Void>()
        let _removeWebLinkTappedInput = PublishSubject<Void>()
        let _backTappedInput = PublishSubject<Void>()

//MARK: - Observers
        self.searchTextInput = _searchTextInput.asObserver()
        self.searchTappedInput = _searchTappedInput.asObserver()
        self.doneTappedInput = _doneTappedInput.asObserver()
        self.removeWebLinkTappedInput = _removeWebLinkTappedInput.asObserver()
        self.backButtonTappedInput = _backTappedInput.asObserver()

//MARK: - First Level Observables
        let searchTextObservable = _searchTextInput.asDriver(onErrorJustReturn: "")
        let searchTappedObservable = _searchTappedInput.asDriver(onErrorJustReturn: ())
        let doneTappedObservable = _doneTappedInput.asDriver(onErrorJustReturn: ())
        let removeWebLinkTappedObservable = _removeWebLinkTappedInput.asDriver(onErrorJustReturn: ())
        let backTappedObservable = _backTappedInput.asDriver(onErrorJustReturn: ())

//MARK: - Outputs
        let webLinkObservable = searchTappedObservable
            .withLatestFrom(searchTextObservable)
            .flatMapLatest {
                thumbnailService.fetchThumbnailFor(url: $0)
                    .trackError(errorTracker)
                    .trackActivity(activityIndicator)
                    .asDriverOnErrorJustComplete()
            }
        
        self.linkThumbnail = Driver.of(webLinkObservable.startWith(nil),
                                       removeWebLinkTappedObservable.map { nil })
            .merge()
        
        self.searchTextIsValid = Driver.of(
            searchTextObservable.map { $0.isNotEmpty ? true : false }.startWith(false),
            removeWebLinkTappedObservable.map { false })
            .merge()
        
        
//MARK: - Routing
        Driver.of(doneTappedObservable, backTappedObservable).merge()
            .do(onNext: router.toMainCreateReplyInput)
            .drive()
            .disposed(by: disposeBag)
        
        }
    
}
