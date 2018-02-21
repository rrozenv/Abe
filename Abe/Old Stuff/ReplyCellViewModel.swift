
import Foundation
import UIKit
import RxSwift
import RxCocoa

//protocol ReplyCellViewModelInputs {
//    /// Call to configure cell with activity value.
//    var reply: PublishSubject<PromptReply> { get }
//}
//
//protocol ReplyCellViewModelOutputs {
//    /// Emits the backer image url to be displayed.
//    var body: Driver<String> { get }
//}
//
//protocol ReplyCellViewModelType {
//    var inputs: ReplyCellViewModelInputs { get }
//    var outputs: ReplyCellViewModelOutputs { get }
//}

struct ReplyCellViewModel {
    
    //MARK: - Inputs
    let reply: AnyObserver<PromptReply>
    
    //MARK: - Output
    let body: Driver<String>
    let name: Driver<String>
    let scoreCellViewModels:  Driver<[ScoreCellViewModel]>
    
    init() {
        guard let user = AppController.shared.currentUser.value else { fatalError() }
        let _reply = PublishSubject<PromptReply>()
        let _replyObservable = _reply.asObservable()
        self.reply = _reply.asObserver()
        
        self.body = _replyObservable
            .debug()
            .map { $0.body }
            .asDriver(onErrorJustReturn: "")
        
        self.name = _replyObservable
            .map { $0.fetchCastedScoreIfExists(for: user.id) }
            .map {  ($0.score != nil) ? $0.reply.user!.name : "Name Locked..." }
            .asDriver(onErrorJustReturn: "")
        
        self.scoreCellViewModels = _replyObservable
            .map { reply in
                return [#imageLiteral(resourceName: "IC_Score_One_Unselected"), #imageLiteral(resourceName: "IC_Score_Two_Unselected"), #imageLiteral(resourceName: "IC_Score_Three_Unselected"), #imageLiteral(resourceName: "IC_Score_Four_Unselected"), #imageLiteral(resourceName: "IC_Score_Five_Unselected")].enumerated().map {
                    let scoreValue = $0.offset + 1
                    let replyScoreIfExists = reply.fetchCastedScoreIfExists(for: user.id)
                    let userDidReply = replyScoreIfExists.score != nil ? true : false
                    let percentage = "\(reply.percentageOfVotesCastesFor(scoreValue: scoreValue))"
                    return ScoreCellViewModel(value: scoreValue,
                                              reply: reply,
                                              userDidReply: userDidReply,
                                              placeholderImage: $0.element,
                                              userScore: replyScoreIfExists.score,
                                              percentage: percentage)
                }
            }
            .asDriver(onErrorJustReturn: [])
    }
    
}
