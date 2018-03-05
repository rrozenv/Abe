
import Foundation
import RxSwift
import RxCocoa
import RxOptional

protocol OnboardingViewModelInputs {
    var viewDidLoadInput: AnyObserver<Void> { get }
    //var nextButtonTappedInput: AnyObserver<Void> { get }
}

protocol OnboardingViewModelOutputs {
    var pageInfo: Driver<(header: String, body: String, buttonTitle: String)> { get }
    //var goToNextPage: Driver<Void> { get }
}

protocol OnboardingViewModelType {
    var inputs: OnboardingViewModelInputs { get }
    var outputs: OnboardingViewModelOutputs { get }
}

final class OnboardingViewModel: OnboardingViewModelType, OnboardingViewModelInputs, OnboardingViewModelOutputs {
    
    let disposeBag = DisposeBag()
    
    //MARK: - Inputs
    var inputs: OnboardingViewModelInputs { return self }
    let viewDidLoadInput: AnyObserver<Void>
    //let nextButtonTappedInput: AnyObserver<Void>
    
    //MARK: - Outputs
    var outputs: OnboardingViewModelOutputs { return self }
    let pageInfo: Driver<(header: String, body: String, buttonTitle: String)>
    //let goToNextPage: Driver<Void>
    
    //MARK: - Init
    init(page: OnboardingPage) {
        
        //MARK: - Subjects
        let _viewDidLoadInput = PublishSubject<Void>()
        let _nextButtonTappedInput = PublishSubject<Void>()
        
        //MARK: - Observers
        self.viewDidLoadInput = _viewDidLoadInput.asObserver()
        //self.nextButtonTappedInput = _nextButtonTappedInput.asObserver()
        
        //MARK: - Outputs
        self.pageInfo = Observable.of(welcomeTextFor(page: page))
            .asDriver(onErrorJustReturn: (header: "", body: "", buttonTitle: ""))
        
        //MARK: - Routing
        //self.goToNextPage = _nextButtonTappedInput.asDriverOnErrorJustComplete()
    }
    
}

private func welcomeTextFor(page: OnboardingPage) -> (header: String, body: String, buttonTitle: String) {
    switch page {
    case .one:
        return (header: "Page 1", body: "This is page 1", buttonTitle: "Button title 1")
    case .two:
        return (header: "Page 2", body: "This is page 2", buttonTitle: "Button title 2")
    }
}
