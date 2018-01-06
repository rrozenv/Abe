
import Foundation
import UIKit
import RxSwift
import RxCocoa

protocol RepliesViewModelInputs {
    /// Call to configure cell with activity value.
    var viewWillAppear: AnyObserver<Void> { get }
}

protocol RepliesViewModelOutputs {
    /// Emits the backer image url to be displayed.
    var replies: Driver<[PromptReply]> { get }
}

struct RepliesViewModel: RepliesViewModelInputs, RepliesViewModelOutputs {
    
    let disposeBag = DisposeBag()
   
    //MARK: - Inputs
    let viewWillAppear: AnyObserver<Void>

    //MARK: - Outputs
    let replies: Driver<[PromptReply]>
    
    private var user: Variable<User>
    
    init(replyService: ReplyService = ReplyService(),
         prompt: Prompt) {
        
        //Make sure current user exists
        guard let user = Application.shared.currentUser.value else { fatalError() }
        self.user = Variable<User>(user)
        
        //Setup viewWillAppear() notification
        let _viewWillAppear = PublishSubject<Void>()
        self.viewWillAppear = _viewWillAppear.asObserver()
        
        //Fetch replies on viewWillAppear()
        let predicate = NSPredicate(format: "promptId = %@", prompt.id)
        self.replies = _viewWillAppear.asObservable().flatMapLatest { _ in
                return replyService.fetchRepliesWith(predicate: predicate)
            }
            .asDriver(onErrorJustReturn: [])
    }
    
}

//        let _prompt = BehaviorSubject<Prompt>(value: prompt)
//        self.prompt = _prompt.asObserver()
