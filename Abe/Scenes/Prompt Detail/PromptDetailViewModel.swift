
import Foundation
import RxSwift
import RxCocoa
import RealmSwift

struct PromptDetailViewModel {
    
    struct Input {
        let reloadTrigger: Driver<Void>
        let createReplyTrigger: Driver<Void>
        let backTrigger: Driver<Void>
    }
    
    struct Output {
        let replies: Driver<List<PromptReply>>
        let createReply: Driver<Void>
        let dismissViewController: Driver<Void>
    }
    
    private let prompt: Prompt
    private let router: PromptDetailRoutingLogic
    private let realm: RealmRepresentable
    
    init(realm: RealmRepresentable, prompt: Prompt, router: PromptDetailRoutingLogic) {
        self.prompt = prompt
        self.router = router
        self.realm = realm
    }
    
    func transform(input: Input) -> Output {
        let replies = Driver.of(prompt.replies)
        
        let repliesUpdate = input.reloadTrigger
            .withLatestFrom(replies)
        
        let createReply = input
            .createReplyTrigger
            .do(onNext: {
                self.router.toCreateReply(for: self.prompt)
            })
        
        let dismiss = input.backTrigger.do(onNext: router.toPrompts)
        
        return Output(replies: repliesUpdate,
                      createReply: createReply,
                      dismissViewController: dismiss)
    }
    
}
