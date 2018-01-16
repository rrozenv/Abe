
import Foundation
import RxSwift
import RxCocoa
import RxOptional

protocol AddWebLinkViewModelInputs {
    var searchTextInput: AnyObserver<String> { get }
    var searchTappedInput: AnyObserver<Void> { get }
}

protocol AddWebLinkViewModelOutputs {
    var linkThumbnail: Observable<WebLinkThumbnail?> { get }
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
    
//MARK: - Outputs
    var outputs: AddWebLinkViewModelOutputs { return self }
    let linkThumbnail: Observable<WebLinkThumbnail?>
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

//MARK: - Observers
        self.searchTextInput = _searchTextInput.asObserver()
        self.searchTappedInput = _searchTappedInput.asObserver()

//MARK: - First Level Observables
        let searchTextObservable = _searchTextInput.asObservable()
        let searchTappedObservable = _searchTappedInput.asObservable()
        
        self.linkThumbnail = searchTappedObservable
            .withLatestFrom(searchTextObservable)
            .flatMapLatest {
                thumbnailService.fetchThumbnailFor(url: $0)
                    .trackError(errorTracker)
                    .trackActivity(activityIndicator)
            }
    }
    
}
