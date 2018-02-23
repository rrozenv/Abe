
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
    var backButtonTappedInput: AnyObserver<Void> { get }
    var rateReplyButtonTappedInput: AnyObserver<(PromptReply, Bool)> { get }
    var viewRatingsForReplyTappedInput: AnyObserver<PromptReply> { get }
}

protocol RepliesViewModelOutputs {
    var didUserReply: Driver<Bool> { get }
    var didSelectFilterOption: Driver<FilterOption> { get }
    var routeToCreateReply: Observable<Void> { get }
    var lockedReplies: Driver<(replies: [ReplyViewModel], userDidReply: Bool)> { get }
    var unlockedReplies: Driver<[ReplyViewModel]> { get }
    var updateReplyWithSavedScore: Driver<(PromptReply, IndexPath)> { get }
    var currentUserReplyAndScores: Driver<(ReplyViewModel, PercentageGraphViewModel)> { get }
    var stillUnreadFromFriendsCount: Driver<Int> { get }
    var prompt: Driver<Prompt> { get }
}

protocol RepliesViewModelType {
    var inputs: RepliesViewModelInputs { get }
    var outputs: RepliesViewModelOutputs { get }
}

final class RepliesViewModel: RepliesViewModelType, RepliesViewModelInputs, RepliesViewModelOutputs {
    
    private let disposeBag = DisposeBag()
   
//MARK: - Inputs
    var inputs: RepliesViewModelInputs { return self }
    let viewWillAppear: AnyObserver<Void>
    let filterOptionSelected: AnyObserver<FilterOption>
    let createReplyTapped: AnyObserver<Void>
    let scoreSelected: AnyObserver<(ScoreCellViewModel, IndexPath)>
    let backButtonTappedInput: AnyObserver<Void>
    let rateReplyButtonTappedInput: AnyObserver<(PromptReply, Bool)>
    let viewRatingsForReplyTappedInput: AnyObserver<PromptReply>

//MARK: - Outputs
    var outputs: RepliesViewModelOutputs { return self }
    let didUserReply: Driver<Bool>
    let didSelectFilterOption: Driver<FilterOption>
    let routeToCreateReply: Observable<Void>
    let lockedReplies: Driver<(replies: [ReplyViewModel], userDidReply: Bool)>
    let unlockedReplies: Driver<[ReplyViewModel]>
    let updateReplyWithSavedScore: Driver<(PromptReply, IndexPath)>
    let currentUserReplyAndScores: Driver<(ReplyViewModel, PercentageGraphViewModel)>
    let stillUnreadFromFriendsCount: Driver<Int>
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
        let _backButtonTappedInput = PublishSubject<Void>()
        let _rateReplyButtonTappedInput = PublishSubject<(PromptReply, Bool)>()
        let _viewRatingsForReplyTappedInput = PublishSubject<PromptReply>()
        
//MARK: - Observers
        self.viewWillAppear = _viewWillAppear.asObserver()
        self.filterOptionSelected = _didSelectFilterOption.asObserver()
        self.createReplyTapped = _createReplyTapped.asObserver()
        self.scoreSelected = _didSelectScore.asObserver()
        self.backButtonTappedInput = _backButtonTappedInput.asObserver()
        self.rateReplyButtonTappedInput = _rateReplyButtonTappedInput.asObserver()
        self.viewRatingsForReplyTappedInput = _viewRatingsForReplyTappedInput.asObserver()

//MARK: - First Level Observables
        let viewWillAppearObservable = _viewWillAppear.asObservable()
        let tabSelectedObservable = _didSelectFilterOption.asObservable()
        let createReplyTappedObservable = _createReplyTapped.asObservable()
        let tableIndexObservable = _didSelectScore.asObservable().map { $0.1 }
        let didSelectScoreObservable = _didSelectScore.asObservable()
        let promptObservable = Observable.of(prompt)
        let backButtonTappedObservable = _backButtonTappedInput.asObservable()
        let rateReplyButtonTappedObservable = _rateReplyButtonTappedInput.asObservable()
        let viewRatingsForReplyTappedObservable = _viewRatingsForReplyTappedInput.asObservable()

//MARK: - Second Level Observables
        let didUserReplyObservable = viewWillAppearObservable
            .map { _ in currentUser.value.didReply(to: prompt) }
        
//        tabSelectedObservable
//            .filter { $0 == .locked && currentUser.value.didReply(to: prompt) }
//            .map { $0.publicRepliesByCurrentUsersFriendsPredicate(currentUser: user) }
//            .map { NSCompoundPredicate(andPredicateWithSubpredicates: $0) }
//            .map { prompt.replies.filter($0) }
//            .do(onNext: { (results) in
//                print("I found \(results.count) results")
//            })
//            .subscribe()
//            .disposed(by: disposeBag)
        
        let lockedRepliesTupleObservable = tabSelectedObservable
            .filter { $0 == .locked }
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
                            resultSelector: { (replies, didUserReply) -> ([ReplyViewModel], Bool) in
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
            .map { ReplyViewModel(reply: $0,
                                  ratingScore: nil,
                                  isCurrentUsersFriend: false,
                                  isUnlocked: true) }
            .map { replyVm in
                (
                    replyVm,
                    [1, 2, 3, 4, 5].map { replyVm.reply.percentageOfVotesCastesFor(scoreValue: $0) }
                )
            }
            .map { replyVm, percentages in
                (
                    replyVm: replyVm,
                    graphVm: PercentageGraphViewModel(userScore: nil,
                                             orderedPercetages: percentages,
                                             totalVotes: replyVm.reply.scores.count)
                )
                
            }
            .asDriverOnErrorJustComplete()
        
        self.updateReplyWithSavedScore = didSelectScoreObservable
            .flatMap { (inputs) -> Observable<(reply: PromptReply, score: ReplyScore)> in
                let scoreVm = inputs.0
                let score = ReplyScore(userId: currentUser.value.id,
                                       replyId: scoreVm.reply.id,
                                       score: scoreVm.value)
                return replyService.saveScore(reply: scoreVm.reply, score: score)
            }
            .flatMap { inputs -> Observable<PromptReply> in
                return replyService
                    .updateAuthorCoinsFor(reply: inputs.reply,
                                          coins: inputs.score.score)
            }
            .withLatestFrom(tableIndexObservable, resultSelector: { (reply, tableIndex) in
                (reply, tableIndex)
            })
            .asDriverOnErrorJustComplete()
        
        self.stillUnreadFromFriendsCount = lockedRepliesTupleObservable
            .map { $0.friends.count }
            .asDriver(onErrorJustReturn: 0)

//MARK: - Routing
        backButtonTappedObservable
            .do(onNext: router.toPrompts)
            .subscribe()
            .disposed(by: disposeBag)
        
        rateReplyButtonTappedObservable
            .do(onNext: { router.toRateReply(reply: $0.0, isCurrentUsersFriend: $0.1) })
            .subscribe()
            .disposed(by: disposeBag)
        
        viewRatingsForReplyTappedObservable
            .do(onNext: { router.toRatingsSummary(reply: $0, userReplyScore: $0.ratingCastedBy(user: user)) })
            .subscribe()
            .disposed(by: disposeBag)
    }
    
}

struct ReplyViewModel {
    let reply: PromptReply
    let ratingScore: ReplyScore?
    let isCurrentUsersFriend: Bool
    let isUnlocked: Bool
}

//MARK: - Helper Methods
private func sortReplies(_ replies: [PromptReply],
                         forLockedFeed: Bool,
                         currentUser: User) -> (friends: [ReplyViewModel], others:[ReplyViewModel]) {
    var userFriendsReplies = [ReplyViewModel]()
    var notFriendsReplies = [ReplyViewModel]()
    for reply in replies {
        let userRating = reply.fetchCastedScoreIfExists(for: currentUser)
        let userDidVote = userRating.score != nil ? true : false
        if forLockedFeed && userDidVote { continue }
        if !forLockedFeed && !userDidVote { continue }
        
        //If reply is viewable only by certain contacts
        guard reply.visibility != Visibility.individualContacts.rawValue else {
            if reply.isViewableBy(currentUser: currentUser) {
                userFriendsReplies.append(
                    ReplyViewModel(reply: reply,
                                   ratingScore: userRating.score,
                                   isCurrentUsersFriend: true,
                                   isUnlocked: forLockedFeed ? false : true)
                )
            }
            continue
        }
        
        //If reply is viewable only by all of user contacts
        guard reply.visibility != Visibility.contacts.rawValue else {
            if reply.isAuthorInCurrentUserContacts(currentUser: currentUser) {
                userFriendsReplies.append(ReplyViewModel(reply: reply, ratingScore: userRating.score, isCurrentUsersFriend: true, isUnlocked: forLockedFeed ? false : true))
            }
            continue
        }
        
        //If reply is viewable by everyone
        if reply.isAuthorInCurrentUserContacts(currentUser: currentUser) {
            userFriendsReplies.append(ReplyViewModel(reply: reply, ratingScore: userRating.score, isCurrentUsersFriend: true, isUnlocked: forLockedFeed ? false : true))
        } else {
            notFriendsReplies.append(ReplyViewModel(reply: reply, ratingScore: userRating.score, isCurrentUsersFriend: false, isUnlocked: forLockedFeed ? false : true))
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


//        let lockedPublicFriendsReplies = tabSelectedObservable
//            .filter { $0 == .locked && currentUser.value.didReply(to: prompt) }
//            .map { $0.publicRepliesByCurrentUsersFriendsPredicate(currentUser: user) }
//            .map { NSCompoundPredicate(andPredicateWithSubpredicates: $0) }
//            .map { prompt.replies.filter($0) }
//
//        let lockedPrivateFriendsReplies = tabSelectedObservable
//            .filter { $0 == .locked && currentUser.value.didReply(to: prompt) }
//            .map { $0.privateRepliesByCurrentUsersFriends(currentUser: user) }
//            .map { NSCompoundPredicate(andPredicateWithSubpredicates: $0) }
//            .map { prompt.replies.filter($0) }
//
//        let lockedPublicNotFriendsReplies = tabSelectedObservable
//            .filter { $0 == .locked && currentUser.value.didReply(to: prompt) }
//            .map { $0.publicRepliesByNotCurrentUsersFriends(currentUser: user) }
//            .map { NSCompoundPredicate(andPredicateWithSubpredicates: $0) }
//            .map { prompt.replies.filter($0) }


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

