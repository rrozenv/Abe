
import Foundation
import RxSwift
import RxCocoa
import UIKit

protocol ProfileViewModelInputs {
    var viewDidLoadInput: AnyObserver<Void> { get }
    var willTransitionToPageInput: AnyObserver<Int> { get }
    var tabVisSelectedInput: AnyObserver<Visibility> { get }
    var didTransitionToPageInput: AnyObserver<Bool> { get }
    var cancelTappedInput: AnyObserver<Void> { get }
}

protocol ProfileViewModelOutputs {
    var configurePagerDataSource: Driver<[Visibility]> { get }
    var navigateToVisibility: Driver<Visibility> { get }
    var currentUser: Driver<User> { get }
    var newProfileImage: Driver<UIImage> { get }
}

protocol ProfileViewModelType {
    var inputs: ProfileViewModelInputs { get }
    var outputs: ProfileViewModelOutputs { get }
}

final class ProfileViewModel: ProfileViewModelType, ProfileViewModelInputs, ProfileViewModelOutputs, PhotoLibraryImagePickedDelegate {
    
    let disposeBag = DisposeBag()
    
    //MARK: - Inputs
    var inputs: ProfileViewModelInputs { return self }
    let viewDidLoadInput: AnyObserver<Void>
    let willTransitionToPageInput: AnyObserver<Int>
    let didTransitionToPageInput: AnyObserver<Bool>
    let tabVisSelectedInput: AnyObserver<Visibility>
    let cancelTappedInput: AnyObserver<Void>
    let selectedImage: AnyObserver<UIImage>

    //MARK: - Outputs
    var outputs: ProfileViewModelOutputs { return self }
    let configurePagerDataSource: Driver<[Visibility]>
    let navigateToVisibility: Driver<Visibility>
    let currentUser: Driver<User>
    let newProfileImage: Driver<UIImage>
    
    //MARK: - Init
    init?(router: ProfileRoutingLogic, userService: UserService = UserService()) {
        guard let user = AppController.shared.currentUser.value else {
            NotificationCenter.default.post(name: Notification.Name.logout, object: nil)
            return nil
        }
        let currentUser = Variable<User>(user)
        let profileVisibilites: [Visibility] = [.currentUserReplied, .currentUserCreated]
        
        //MARK: - Subjects
        let _viewDidLoadInput = PublishSubject<Void>()
        let _willTransitionToPageInput = PublishSubject<Int>()
        let _didTransitionToPageInput = PublishSubject<Bool>()
        let _tabVisSelectedInput = PublishSubject<Visibility>()
        let _cancelTappedInput = PublishSubject<Void>()
        let _selectedProfileImage = PublishSubject<UIImage>()
        
        //MARK: - Observers
        self.viewDidLoadInput = _viewDidLoadInput.asObserver()
        self.willTransitionToPageInput = _willTransitionToPageInput.asObserver()
        self.didTransitionToPageInput = _didTransitionToPageInput.asObserver()
        self.tabVisSelectedInput = _tabVisSelectedInput.asObserver()
        self.cancelTappedInput = _cancelTappedInput.asObserver()
        self.selectedImage = _selectedProfileImage.asObserver()
        
        //MARK: - First Level Observables
        //let viewDidLoadObservable = _viewDidLoadInput.asObservable()
        let willTransitionToPageObservable = _willTransitionToPageInput.asObservable()
        let didTransitionToPageObservable = _didTransitionToPageInput.asObservable()
        let tabSelectedObservable = _tabVisSelectedInput.asObservable()
        let cancelTappedObservable = _cancelTappedInput.asObservable()
        let selectedProfileImageObservable = _selectedProfileImage.asObservable().share()
        
        let visibilityToShowObservabele = Observable.of(
            didTransitionToPageObservable
                .filter{ $0 }
                .withLatestFrom(willTransitionToPageObservable)
                .map { profileVisibilites[$0] },
            tabSelectedObservable).merge()
        
        //MARK: - Outputs
        self.configurePagerDataSource = Driver.of(profileVisibilites)
        self.navigateToVisibility = visibilityToShowObservabele.asDriverOnErrorJustComplete()
        self.currentUser = Driver.of(currentUser.value)
        self.newProfileImage = selectedProfileImageObservable
            .asDriverOnErrorJustComplete()
        
        selectedProfileImageObservable
            .map { UIImageJPEGRepresentation($0, 0.8) }.unwrap()
            .flatMap { userService.update(imageData: $0, for: user) }
            .do(onNext: { AppController.shared.currentUser.value = $0 })
            .subscribe()
            .disposed(by: disposeBag)
        
        cancelTappedObservable
            .do(onNext: router.toHome)
            .subscribe()
            .disposed(by: disposeBag)
    }
    
}

