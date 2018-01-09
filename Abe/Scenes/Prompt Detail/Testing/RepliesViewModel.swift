
import Foundation
import UIKit
import RxSwift
import RxCocoa
import RealmSwift

protocol RepliesViewModelInputs {
    var viewWillAppear: AnyObserver<Void> { get }
    var visibilitySelected: AnyObserver<Visibility> { get }
    var createReplyTapped: AnyObserver<Void> { get }
}

protocol RepliesViewModelOutputs {
    var didUserReply: Driver<Bool> { get }
    var currentVisibility: Driver<Visibility> { get }
    var allReplies: Driver<Results<PromptReply>> { get }
    var contactReplies: Driver<[PromptReply]> { get }
    var routeToCreateReply: Observable<Void> { get }
    var lockedReplies: Driver<[PromptReply]> { get }
    var unlockedReplies: Driver<[PromptReply]> { get }
}

protocol RepliesViewModelType {
    var inputs: RepliesViewModelInputs { get }
    var outputs: RepliesViewModelOutputs { get }
}

final class RepliesViewModel: RepliesViewModelType, RepliesViewModelInputs, RepliesViewModelOutputs {
    
    let disposeBag = DisposeBag()
   
    //MARK: - Inputs
    var inputs: RepliesViewModelInputs { return self }
    let viewWillAppear: AnyObserver<Void>
    let visibilitySelected: AnyObserver<Visibility>
    let createReplyTapped: AnyObserver<Void>

    //MARK: - Outputs
    var outputs: RepliesViewModelOutputs { return self }
    let didUserReply: Driver<Bool>
    let currentVisibility: Driver<Visibility>
    let allReplies: Driver<Results<PromptReply>>
    let contactReplies: Driver<[PromptReply]>
    let routeToCreateReply: Observable<Void>
    let lockedReplies: Driver<[PromptReply]>
    let unlockedReplies: Driver<[PromptReply]>

    init?(replyService: ReplyService = ReplyService(),
         router: PromptDetailRoutingLogic,
         prompt: Prompt) {
        
        //Make sure current user exists
        guard let user = AppController.shared.currentUser.value else {
            NotificationCenter
                .default.post(name: Notification.Name.logout, object: nil)
            return nil
        }
        
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
                let replies = prompt.replies
                    .filter(predicateMatching(visibility: .all,
                                              userId: currentUser.value.id))
                return replies
            }
            .asDriverOnErrorJustComplete()
        
        let contactOnlyReplies = _shouldFetch
            .map { _ -> [PromptReply] in
                return prompt.replies
                    .filter(predicateMatching(visibility: .contacts,
                                              userId: currentUser.value.id))
                    .toArray()
                    .filter {
                        $0.isAuthorInCurrentUserContacts(currentUser: currentUser.value)
                    }
            }
        
        let allReplies = _shouldFetch
            .map { _ -> [PromptReply] in
                let replies = prompt.replies
                    .filter(predicateMatching(visibility: .all,
                                              userId: currentUser.value.id))
                    .toArray()
                return replies
            }
        
        self.lockedReplies = contactOnlyReplies
            .map { contactReplies -> [PromptReply] in
                let allReplies = prompt.replies
                    .filter(predicateMatching(visibility: .all,
                                              userId: currentUser.value.id))
                    .toArray()
                return contactReplies + allReplies
            }
            .map { $0.filter { !didUserCastScoreFor(reply: $0, userId: currentUser.value.id) } }
            .asDriver(onErrorJustReturn: [])
        
        self.unlockedReplies = contactOnlyReplies.concat(allReplies)
            .map { $0.filter { didUserCastScoreFor(reply: $0, userId: currentUser.value.id) } }
            .asDriver(onErrorJustReturn: [])
        
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

private func predicateMatching(visibility: Visibility,
                               userId: String) -> NSCompoundPredicate {
    let bySelectedVis = NSPredicate(format: "visibility = %@", visibility.rawValue)
    let removeUsersReply = NSPredicate(format: "user.id != %@", userId)
    return NSCompoundPredicate(andPredicateWithSubpredicates: [bySelectedVis, removeUsersReply])
}

private func didUserCastScoreFor(reply: PromptReply,
                                 userId: String) -> Bool {
    let userScoreIfExists = reply.fetchCastedScoreIfExists(for: userId).score
    return (userScoreIfExists != nil) ? true : false
}

