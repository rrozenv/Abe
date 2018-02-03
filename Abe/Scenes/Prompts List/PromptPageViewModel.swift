
import Foundation
import RxSwift
import RxCocoa

protocol PromptPageViewModelInputs {
    var viewDidLoadInput: AnyObserver<Void> { get }
    var willTransitionToPageInput: AnyObserver<Int> { get }
    var tabVisSelectedInput: AnyObserver<Visibility> { get }
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
    let tabVisSelectedInput: AnyObserver<Visibility>
    
    //MARK: - Outputs
    var outputs: PromptPageViewModelOutputs { return self }
    let configurePagerDataSource: Driver<[Visibility]>
    let navigateToVisibility: Driver<Visibility>
    
    //MARK: - Init
    init?() {
        guard let user = AppController.shared.currentUser.value else {
            NotificationCenter.default.post(name: Notification.Name.logout, object: nil)
            return nil
        }
        //let currentUser = Variable<User>(user)
        let visibilites: [Visibility] = [.all, .individualContacts]
        
        //MARK: - Subjects
        let _viewDidLoadInput = PublishSubject<Void>()
        let _willTransitionToPageInput = PublishSubject<Int>()
        let _tabVisSelectedInput = PublishSubject<Visibility>()
        
        //MARK: - Observers
        self.viewDidLoadInput = _viewDidLoadInput.asObserver()
        self.willTransitionToPageInput = _willTransitionToPageInput.asObserver()
        self.tabVisSelectedInput = _tabVisSelectedInput.asObserver()
        
        //MARK: - First Level Observables
        //let viewDidLoadObservable = _viewDidLoadInput.asObservable()
        let willTransitionToPageObservable = _willTransitionToPageInput.asObservable()
        let tabSelectedObservable = _tabVisSelectedInput.asObservable()
        let visibilityToShowObservabele = Observable.of(willTransitionToPageObservable.map { visibilites[$0] }, tabSelectedObservable).merge()
        
        //MARK: - Outputs
        self.configurePagerDataSource = Driver.of(visibilites)
        self.navigateToVisibility = visibilityToShowObservabele.asDriverOnErrorJustComplete()
    }
    
}
