//
//  CreateReplyViewModel.swift
//  OutpostRxSwift
//
//  Created by Robert Rozenvasser on 12/13/17.
//  Copyright © 2017 Cluk Labs. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Action
import RealmSwift

struct CreateReplyViewModel {
    
    struct Input {
        let body: Driver<String>
        let createTrigger: Driver<Void>
        let cancelTrigger: Driver<Void>
    }
    
    struct Output {
        let inputIsValid: Driver<Bool>
        let loading: Driver<Bool>
        let errors: Driver<Error>
        let promptDidUpdate: Observable<Void>
    }
    
    private let realm: RealmRepresentable
    private let router: CreateReplyRoutingLogic
    private let prompt: Prompt
    private let user: UserInfo
    
    var promptTitle: String { return prompt.title }
    
    init(realm: RealmRepresentable, prompt: Prompt, router: CreateReplyRoutingLogic) {
        self.prompt = prompt
        self.realm = realm
        self.router = router
        guard let userInfo = UserDefaultsManager.userInfo() else { fatalError() }
        self.user = userInfo
    }
    
    func transform(input: Input) -> Output {
        let activityIndicator = ActivityIndicator()
        let errorTracker = ErrorTracker()
        let loading = activityIndicator.asDriver()
        let errors = errorTracker.asDriver()
        
        let inputIsValid = input.body.map { $0.count > 10 }
        let currentPrompt = Observable.of(prompt)

        let reply = Observable.combineLatest(currentPrompt, input.body.asObservable()) { (currentPrompt, replyBody) -> PromptReply in
            return PromptReply(userId: self.user.id,
                               userName: self.user.name,
                               promptId: self.prompt.id,
                               body: replyBody)
        }
  
        let promptDidUpdate = input.createTrigger
            .asObservable()
            .withLatestFrom(reply)
            .flatMapLatest { (reply) -> Observable<Void> in
                return self.realm.update {
                    self.prompt.replies.insert(reply, at: 0)
                }
                .trackActivity(activityIndicator)
                .trackError(errorTracker)
            }
            .do(onNext: router.toPromptDetail)
        
        return Output(inputIsValid: inputIsValid,
                      loading: loading,
                      errors: errors,
                      promptDidUpdate: promptDidUpdate)
    }
    
//    func transform(input: Input) -> Output {
//        let inputIsValid = input.body.map { $0.count > 10 }
//
//        let currentPrompt = Observable.of(prompt)
//
////        let reply = Driver.combineLatest(currentPrompt, input.body) { (currentPrompt, replyBody) -> PromptReply in
////            return PromptReply(prompt: currentPrompt, body: replyBody)
////        }
//
//        let creply = Observable.combineLatest(currentPrompt, input.body.asObservable()) { (currentPrompt, replyBody) -> PromptReply in
//            return PromptReply(prompt: currentPrompt, body: replyBody)
//        }
//
//        let newReply = input.createTrigger.asObservable()
//            .withLatestFrom(creply)
//            .flatMapLatest { (reply) -> Observable<Void> in
//                return self.promptDataStorage.update(block: {
//                    self.prompt.replies.append(reply)
//                })
//            }
//            .do(onNext: router.toPromptDetail)
//
////        let updatePrompt = input.createTrigger
////            .withLatestFrom(reply)
////            .flatMapLatest { (reply) -> SharedSequence<DriverSharingStrategy, Void> in
////                return self.promptDataStorage.update(block: {
////                    self.prompt.replies.append(reply)
////                })
////                .asDriverOnErrorJustComplete()
////            }
////            .do(onNext: router.toPromptDetail)
//
////        let dismiss = Driver.of(updatePrompt, input.cancelTrigger)
////            .merge()
////            .do(onNext: router.toPromptDetail)
//
////        let dismiss = Driver.merge([updatePrompt, input.cancelTrigger])
////            .do(onNext: router.toPromptDetail)
//
//        return Output(inputIsValid: inputIsValid, updatePrompt: newReply)
//    }
    

    
}
