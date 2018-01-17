
import Foundation
import UIKit
import RxSwift
import RxCocoa
import RealmSwift

protocol RepliesViewModelInputs {
    var viewWillAppear: AnyObserver<Void> { get }
    var filterOptionSelected: AnyObserver<FilterOption> { get }
    var createReplyTapped: AnyObserver<Void> { get }
    var scoreSelected: AnyObserver<(ScoreCellViewModel, IndexPath)> { get }
}

protocol RepliesViewModelOutputs {
    var didUserReply: Driver<Bool> { get }
    var didSelectFilterOption: Driver<FilterOption> { get }
    var routeToCreateReply: Observable<Void> { get }
    var lockedReplies: Driver<(replies: [PromptReply], userDidReply: Bool)> { get }
    var unlockedReplies: Driver<[PromptReply]> { get }
    var updateReplyWithSavedScore: Driver<(PromptReply, IndexPath)> { get }
    var currentUserReplyAndScores: Driver<(PromptReply, [ReplyScore])> { get }
    var stillUnreadFromFriendsCount: Driver<String> { get }
    var prompt: Driver<Prompt> { get }
}

protocol RepliesViewModelType {
    var inputs: RepliesViewModelInputs { get }
    var outputs: RepliesViewModelOutputs { get }
}

enum FilterOption: Int {
    case locked = 1
    case unlocked = 2
    case myReply = 3
}

final class RepliesViewModel: RepliesViewModelType, RepliesViewModelInputs, RepliesViewModelOutputs {
    
    private let disposeBag = DisposeBag()
   
//MARK: - Inputs
    var inputs: RepliesViewModelInputs { return self }
    let viewWillAppear: AnyObserver<Void>
    let filterOptionSelected: AnyObserver<FilterOption>
    let createReplyTapped: AnyObserver<Void>
    let scoreSelected: AnyObserver<(ScoreCellViewModel, IndexPath)>

//MARK: - Outputs
    var outputs: RepliesViewModelOutputs { return self }
    let didUserReply: Driver<Bool>
    let didSelectFilterOption: Driver<FilterOption>
    let routeToCreateReply: Observable<Void>
    let lockedReplies: Driver<(replies: [PromptReply], userDidReply: Bool)>
    let unlockedReplies: Driver<[PromptReply]>
    let updateReplyWithSavedScore: Driver<(PromptReply, IndexPath)>
    let currentUserReplyAndScores: Driver<(PromptReply, [ReplyScore])>
    let stillUnreadFromFriendsCount: Driver<String>
    let prompt: Driver<Prompt>

//MARK: - Init
    init?(replyService: ReplyService = ReplyService(),
         router: PromptDetailRoutingLogic,
         prompt: Prompt) {
        guard let user = AppController.shared.currentUser.value else {
            NotificationCenter.default.post(name: Notification.Name.logout, object: nil)
            return nil
        }
        let currentUser = Variable<User>(user)
        
//MARK: - Subjects
        let _didSelectFilterOption = PublishSubject<FilterOption>()
        let _createReplyTapped = PublishSubject<Void>()
        let _viewWillAppear = PublishSubject<Void>()
        let _didSelectScore = PublishSubject<(ScoreCellViewModel, IndexPath)>()
        
//MARK: - Observers
        self.viewWillAppear = _viewWillAppear.asObserver()
        self.filterOptionSelected = _didSelectFilterOption.asObserver()
        self.createReplyTapped = _createReplyTapped.asObserver()
        self.scoreSelected = _didSelectScore.asObserver()

//MARK: - First Level Observables
        let viewWillAppearObservable = _viewWillAppear.asObservable()
        let tabSelectedObservable = _didSelectFilterOption.asObservable()
        let createReplyTappedObservable = _createReplyTapped.asObservable()
        let tableIndexObservable = _didSelectScore.asObservable().map { $0.1 }
        let didSelectScoreObservable = _didSelectScore.asObservable()
        let promptObservable = Observable.of(prompt)

//MARK: - Second Level Observables
        let didUserReplyObservable = viewWillAppearObservable
            .map { _ in currentUser.value.didReply(to: prompt) }
        let lockedRepliesTupleObservable = tabSelectedObservable
            .filter { $0 == .locked }
            .map { _ in currentUser.value.didReply(to: prompt) }
            .map { _ in prompt.replies.toArray() }
            .map { sortReplies($0,
                               forLockedFeed: true,
                               currentUser: currentUser.value)
            }
        let lockedRepliesObservable = lockedRepliesTupleObservable.map { $0.friends + $0.others }
        
//MARK: - Outer Observables
        self.didSelectFilterOption = tabSelectedObservable.asDriver(onErrorJustReturn: .locked)
        self.prompt = promptObservable.asDriverOnErrorJustComplete()
        self.didUserReply = didUserReplyObservable.asDriver(onErrorJustReturn: false)
        
        self.lockedReplies = lockedRepliesObservable
            .withLatestFrom(didUserReplyObservable,
                            resultSelector: { (replies, didUserReply) -> ([PromptReply], Bool) in
                                return (replies, didUserReply)
            })
            .asDriver(onErrorJustReturn: ([], false))
        
        self.unlockedReplies = tabSelectedObservable
            .filter { $0 == .unlocked }
            .map { _ in prompt.replies.toArray() }
            .map { sortReplies($0,
                               forLockedFeed: false,
                               currentUser: currentUser.value) }
            .map { $0.friends + $0.others }
            .asDriver(onErrorJustReturn: [])
        
        self.routeToCreateReply = createReplyTappedObservable
            .do(onNext: { router.toCreateReply(for: prompt) })
        
        self.currentUserReplyAndScores = tabSelectedObservable
            .filter { $0 == .myReply }
            .map { _ in currentUser.value.reply(to: prompt) }
            .unwrap()
            .map { ($0, $0.scores.toArray()) }
            .asDriverOnErrorJustComplete()
        
        self.updateReplyWithSavedScore = didSelectScoreObservable
            .flatMap { (inputs) -> Observable<(PromptReply, ReplyScore)> in
                let scoreVm = inputs.0
                let score = ReplyScore(userId: currentUser.value.id,
                                       replyId: scoreVm.reply.id,
                                       score: scoreVm.value)
                return replyService.saveScore(reply: scoreVm.reply, score: score)
            }
            .flatMap { replyAndScore -> Observable<PromptReply> in
                return replyService
                    .updateAuthorCoinsFor(reply: replyAndScore.0,
                                          coins: replyAndScore.1.score)
            }
            .withLatestFrom(tableIndexObservable, resultSelector: { (reply, tableIndex) in
                (reply, tableIndex)
            })
            .asDriverOnErrorJustComplete()
        
        self.stillUnreadFromFriendsCount = lockedRepliesTupleObservable
            .map { "\($0.friends.count) replies from friends still locked!" }
            .asDriver(onErrorJustReturn: "")
    }
    
}

//MARK: - Helper Methods
private func sortReplies(_ replies: [PromptReply],
                         forLockedFeed: Bool,
                         currentUser: User) -> (friends: [PromptReply], others:[PromptReply]) {
    var userFriendsReplies = [PromptReply]()
    var notFriendsReplies = [PromptReply]()
    for reply in replies {
        let userDidVote = reply.doesScoreExistFor(userId: currentUser.id)
        if forLockedFeed && userDidVote { continue }
        if !forLockedFeed && !userDidVote { continue }
        
        //If reply is viewable only by certain contacts
        guard reply.visibility != Visibility.individualContacts.rawValue else {
            if reply.isViewableBy(currentUser: currentUser) {
                userFriendsReplies.append(reply)
            }
            continue
        }
        
        //If reply is viewable only by all of user contacts
        guard reply.visibility != Visibility.contacts.rawValue else {
            if reply.isAuthorInCurrentUserContacts(currentUser: currentUser) {
                userFriendsReplies.append(reply)
            }
            continue
        }
        
        //If reply is viewable by everyone
        if reply.isAuthorInCurrentUserContacts(currentUser: currentUser) {
            userFriendsReplies.append(reply)
        } else {
            notFriendsReplies.append(reply)
        }
    }
    return (userFriendsReplies, notFriendsReplies)
}

private func mergeAndRandomize(friends: [PromptReply], others:[PromptReply], percentage: Double) -> [PromptReply] {
    guard friends.count > 0 || others.count > 0 else { return friends + others }
    let indexEstimate = (Double(friends.count)) / percentage
    let index = Int(indexEstimate) - friends.count
    guard index < others.count else { return friends + others }
    let othersNeeded = others.split(at: index).left
    let unrandomizedTopReplies = friends + othersNeeded
    let topRepliesRandomized = unrandomizedTopReplies.shuffled()
    let remainingReplies = others[othersNeeded.count..<others.count]
    return topRepliesRandomized + remainingReplies
}

//private func didUserCastScoreFor(reply: PromptReply,
//                                 userId: String) -> Bool {
//    let userScoreIfExists = reply.fetchCastedScoreIfExists(for: userId).score
//    return (userScoreIfExists != nil) ? true : false
//}


//self.allReplies = _shouldFetch
//    .withLatestFrom(_visibilitySelected.asObservable())
//    .filter { $0.rawValue == Visibility.all.rawValue }
//    .map { vis -> Results<PromptReply> in
//        let replies = prompt.replies
//            .filter(predicateMatching(visibility: .all,
//                                      userId: currentUser.value.id))
//        return replies
//    }
//    .asDriverOnErrorJustComplete()

//let contactOnlyReplies = _shouldFetch
//    .map { _ -> [PromptReply] in
//        return prompt.replies
//            .filter(predicateMatching(visibility: .contacts,
//                                      userId: currentUser.value.id))
//            .toArray()
//            .filter {
//                $0.isAuthorInCurrentUserContacts(currentUser: currentUser.value)
//        }
//}
//
//let allReplies = _shouldFetch
//    .map { _ -> [PromptReply] in
//        let replies = prompt.replies
//            .filter(predicateMatching(visibility: .all,
//                                      userId: currentUser.value.id))
//            .toArray()
//        return replies
//}

//self.lockedReplies = contactOnlyReplies
//    .map { contactReplies -> [PromptReply] in
//        let allReplies = prompt.replies
//            .filter(predicateMatching(visibility: .all,
//                                      userId: currentUser.value.id))
//            .toArray()
//        return contactReplies + allReplies
//    }
//    .map { $0.filter { !didUserCastScoreFor(reply: $0, userId: currentUser.value.id) } }
//    .asDriver(onErrorJustReturn: [])
//
//self.unlockedReplies = contactOnlyReplies.concat(allReplies)
//    .map { $0.filter { didUserCastScoreFor(reply: $0, userId: currentUser.value.id) } }
//    .asDriver(onErrorJustReturn: [])
//
//self.contactReplies = _shouldFetch
//    .withLatestFrom(_visibilitySelected.asObservable())
//    .filter { $0 == Visibility.contacts }
//    .map { vis in
//        let bySelectedVis = NSPredicate(format: "visibility = %@",
//                                        vis.rawValue)
//        return prompt.replies
//            .filter(bySelectedVis)
//            .toArray()
//            .filter { $0.isAuthorInCurrentUserContacts(currentUser: currentUser.value) }
//    }
//    .asDriver(onErrorJustReturn: [])

//private func predicateMatching(visibility: Visibility,
//                               userId: String) -> NSCompoundPredicate {
//    let bySelectedVis = NSPredicate(format: "visibility = %@", visibility.rawValue)
//    let removeUsersReply = NSPredicate(format: "user.id != %@", userId)
//    return NSCompoundPredicate(andPredicateWithSubpredicates: [bySelectedVis, removeUsersReply])
//}

