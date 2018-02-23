
import Foundation
import RxSwift
import RxCocoa

protocol WebLinkViewModelInputs {
    var viewDidLoadInput: AnyObserver<Void> { get }
    var backButtonTappedInput: AnyObserver<Void> { get }
    var activityIndicator: Driver<Bool> { get }
    var errorTracker: Driver<Error> { get }
}

protocol WebLinkViewModelOutputs {
    var webUrl: Driver<URL?> { get }
}

protocol WebLinkViewModelType {
    var inputs: WebLinkViewModelInputs { get }
    var outputs: WebLinkViewModelOutputs { get }
}

final class WebLinkViewModel: WebLinkViewModelType, WebLinkViewModelInputs, WebLinkViewModelOutputs {
    
    let disposeBag = DisposeBag()
    
    //MARK: - Inputs
    var inputs: WebLinkViewModelInputs { return self }
    let viewDidLoadInput: AnyObserver<Void>
    let backButtonTappedInput: AnyObserver<Void>
    
    //MARK: - Outputs
    var outputs: WebLinkViewModelOutputs { return self }
    let webUrl: Driver<URL?>
    let activityIndicator: Driver<Bool>
    let errorTracker: Driver<Error>
    
    //MARK: - Init
    init(urlString: String) {
        let activityIndicator = ActivityIndicator()
        let errorTracker = ErrorTracker()
        self.activityIndicator = activityIndicator.asDriver()
        self.errorTracker = errorTracker.asDriver()
        
        //MARK: - Subjects
        let _viewDidLoadInput = PublishSubject<Void>()
        let _backTappedInput = PublishSubject<Void>()
        
        //MARK: - Observers
        self.viewDidLoadInput = _viewDidLoadInput.asObserver()
        self.backButtonTappedInput = _backTappedInput.asObserver()
        
        //MARK: - First Level Observables
        let viewDidLoadObservable = _viewDidLoadInput.asObservable()
        let backTappedObservable = _backTappedInput.asDriver(onErrorJustReturn: ())
        
        //MARK: - Outputs
        self.webUrl = viewDidLoadObservable
            .map { _ in URL(string: urlString) }
            .asSharedSequence(onErrorJustReturn: URL(string: ""))
    }
    
}
