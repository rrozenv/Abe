//
//  RepliesViewModel.swift
//  Abe
//
//  Created by Robert Rozenvasser on 1/5/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

//protocol RepliesViewModelInputs {
//    /// Call to configure cell with activity value.
//    var viewWillAppear: PublishSubject<Void> { get }
//}
//
//protocol RepliesViewModelOutputs {
//    /// Emits the backer image url to be displayed.
//    var replies: Driver<[PromptReply]> { get }
//}
//
//protocol RepliesViewModelType {
//    var inputs: RepliesViewModelInputs { get }
//    var outputs: RepliesViewModelOutputs { get }
//}

struct RepliesViewModel {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
   
    // MARK: -
    struct Input {
        let viewWillAppear: Observable<Void>
    }
    
    struct Output {
        let replies: Driver<[PromptReply]>
    }
    
    private let prompt: Prompt
    private let replyService: ReplyService
    private var user: Variable<User>
    
    init(replyService: ReplyService,
         prompt: Prompt) {
        guard let user = Application.shared.currentUser.value else { fatalError() }
        self.user = Variable<User>(user)
        self.prompt = prompt
        self.replyService = replyService
    }
    
    func transform(input: Input) -> Output {
       
        let predicate = NSPredicate(format: "promptId = %@", prompt.id)
        let replies = input.viewWillAppear
            .flatMapLatest { _ in
                return self.replyService
                    .fetchRepliesWith(predicate: predicate)
            }
            .asDriver(onErrorJustReturn: [])
        
        return Output(replies: replies)
    }
}
