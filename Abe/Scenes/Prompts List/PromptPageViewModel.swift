
import Foundation
import RxSwift
import RxCocoa

protocol PromptPageViewModelInputs {
    var viewDidLoadInput: AnyObserver<Void> { get }
    var willTransitionToPageInput: AnyObserver<Int> { get }
    var tabVisSelectedInput: AnyObserver<Visibility> { get }
    var didTransitionToPageInput: AnyObserver<Bool> { get }
    var createPromptTappedInput: AnyObserver<Void> { get }
}

protocol PromptPageViewModelOutputs {
    var configurePagerDataSource: Driver<[Visibility]> { get }
    var navigateToVisibility: Driver<Visibility> { get }
}

protocol PromptPageViewModelType {
    var inputs: PromptPageViewModelInputs { get }
    var outputs: PromptPageViewModelOutputs { get }
}

final class PromptPageViewModel: PromptPageViewModelType, PromptPageViewModelInputs, PromptPageViewModelOutputs {
    
    let disposeBag = DisposeBag()
    
    //MARK: - Inputs
    var inputs: PromptPageViewModelInputs { return self }
    let viewDidLoadInput: AnyObserver<Void>
    let willTransitionToPageInput: AnyObserver<Int>
    let didTransitionToPageInput: AnyObserver<Bool>
    let tabVisSelectedInput: AnyObserver<Visibility>
    let createPromptTappedInput: AnyObserver<Void>
    
    //MARK: - Outputs
    var outputs: PromptPageViewModelOutputs { return self }
    let configurePagerDataSource: Driver<[Visibility]>
    let navigateToVisibility: Driver<Visibility>
    
    //MARK: - Init
    init?(router: PromptPageRoutingLogic) {
        guard let user = AppController.shared.currentUser.value else {
            NotificationCenter.default.post(name: Notification.Name.logout, object: nil)
            return nil
        }
        //let currentUser = Variable<User>(user)
        let visibilites: [Visibility] = [.all, .individualContacts]
        
        //MARK: - Subjects
        let _viewDidLoadInput = PublishSubject<Void>()
        let _willTransitionToPageInput = PublishSubject<Int>()
        let _didTransitionToPageInput = PublishSubject<Bool>()
        let _tabVisSelectedInput = PublishSubject<Visibility>()
        let _createPromptTappedInput = PublishSubject<Void>()
        
        //MARK: - Observers
        self.viewDidLoadInput = _viewDidLoadInput.asObserver()
        self.willTransitionToPageInput = _willTransitionToPageInput.asObserver()
        self.didTransitionToPageInput = _didTransitionToPageInput.asObserver()
        self.tabVisSelectedInput = _tabVisSelectedInput.asObserver()
        self.createPromptTappedInput = _createPromptTappedInput.asObserver()
        
        //MARK: - First Level Observables
        //let viewDidLoadObservable = _viewDidLoadInput.asObservable()
        let willTransitionToPageObservable = _willTransitionToPageInput.asObservable()
        let didTransitionToPageObservable = _didTransitionToPageInput.asObservable()
        let tabSelectedObservable = _tabVisSelectedInput.asObservable()
        let createPromptTappedObservable = _createPromptTappedInput.asObservable()
//            .withLatestFrom(willTransitionToPageObservable)
//            .map { visibilites[$0] }
//            .scan((Visibility.all, false)) { (lastVis, currentVis) -> (Visibility, Bool) in
//                return lastVis.0 == currentVis ? (currentVis, false) : (currentVis, true)
//            }
        
        let visibilityToShowObservabele = Observable.of(
            didTransitionToPageObservable
                .filter{ $0 }
                .withLatestFrom(willTransitionToPageObservable)
                .map { visibilites[$0] },
            tabSelectedObservable).merge()
        
        //MARK: - Outputs
        self.configurePagerDataSource = Driver.of(visibilites)
        self.navigateToVisibility = visibilityToShowObservabele.asDriverOnErrorJustComplete()
        
        createPromptTappedObservable
            .do(onNext: router.toCreatePrompt)
            .subscribe()
            .disposed(by: disposeBag)
    }
    
}
