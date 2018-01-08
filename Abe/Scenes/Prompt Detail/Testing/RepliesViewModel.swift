
import Foundation
import UIKit
import RxSwift
import RxCocoa
import RealmSwift

protocol RepliesViewModelInputs {
    /// Call to configure cell with activity value.
    var viewWillAppear: AnyObserver<Void> { get }
}

protocol RepliesViewModelOutputs {
    /// Emits the backer image url to be displayed.
    var allReplies: Driver<Results<PromptReply>> { get }
}

final class RepliesViewModel: RepliesViewModelInputs, RepliesViewModelOutputs {
    
    let disposeBag = DisposeBag()
   
    //MARK: - Inputs
    let viewWillAppear: AnyObserver<Void>
    let visibilitySelected: AnyObserver<Visibility>
    let createReplyTapped: AnyObserver<Void>

    //MARK: - Outputs
    let didUserReply: Driver<Bool>
    let currentVisibility: Driver<Visibility>
    let allReplies: Driver<Results<PromptReply>>
    let contactReplies: Driver<[PromptReply]>
    let routeToCreateReply: Observable<Void>

    init(replyService: ReplyService = ReplyService(),
         router: PromptDetailRoutingLogic,
         prompt: Prompt) {
        
        //Make sure current user exists
        guard let user = Application.shared.currentUser.value else { fatalError() }
        let currentUser = Variable<User>(user)
        
        let _visibilitySelected = BehaviorSubject<Visibility>(value: .all)
        self.visibilitySelected = _visibilitySelected.asObserver()
        self.currentVisibility = _visibilitySelected.asDriver(onErrorJustReturn: .all)
        
        let _createReplyTapped = PublishSubject<Void>()
        self.createReplyTapped = _createReplyTapped.asObserver()
        self.routeToCreateReply = _createReplyTapped.asObservable()
            .do(onNext: { router.toCreateReply(for: prompt) })
        
        //Setup viewWillAppear() notification
        let _viewWillAppear = PublishSubject<Void>()
        self.viewWillAppear = _viewWillAppear.asObserver()
        
        let _didUserReply = _viewWillAppear.asObservable()
            .map { _ in currentUser.value.didReply(to: prompt) }
        self.didUserReply = _didUserReply.asDriver(onErrorJustReturn: false)
        
        let _visibilityWhenViewAppears = _viewWillAppear.asObservable()
            .flatMap { _visibilitySelected.asObservable() }
        
        let _visibilityToFetch = Observable
            .merge(_visibilityWhenViewAppears, self.currentVisibility.asObservable())
            .skip(1)
            .debug()
        
        let _shouldFetch = _visibilityToFetch.asObservable()
            .withLatestFrom(_didUserReply)
            .filter { $0 }
            .share()
        
        self.allReplies = _shouldFetch
            .withLatestFrom(_visibilitySelected.asObservable())
            .filter { $0.rawValue == Visibility.all.rawValue }
            .map { vis -> Results<PromptReply> in
                let bySelectedVis = NSPredicate(format: "visibility = %@", vis.rawValue)
                let removeUsersReply = NSPredicate(format: "user.id != %@", currentUser.value.id)
                let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [bySelectedVis, removeUsersReply])
                let replies = prompt.replies
                    .filter(predicate)
                    //.filter { $0.user?.id != currentUser.value.id }
                return replies
            }
            .asDriverOnErrorJustComplete()
        
        self.contactReplies = _shouldFetch
            .withLatestFrom(_visibilitySelected.asObservable())
            .filter { $0 == Visibility.contacts }
            .map { vis in
                let bySelectedVis = NSPredicate(format: "visibility = %@",
                                                vis.rawValue)
                return prompt.replies
                    .filter(bySelectedVis)
                    .toArray()
                    .filter { $0.isAuthorInCurrentUserContacts(currentUser: currentUser.value) }
            }
            .asDriver(onErrorJustReturn: [])
    }
    
}

//        let _prompt = BehaviorSubject<Prompt>(value: prompt)
//        self.prompt = _prompt.asObserver()
