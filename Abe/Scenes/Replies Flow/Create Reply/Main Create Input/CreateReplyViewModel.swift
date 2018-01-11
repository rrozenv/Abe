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
        let currentPrompt: Driver<Prompt>
        let promptDidUpdate: Observable<Void>
        let loading: Driver<Bool>
        let errors: Driver<Error>
    }
    
    private let router: CreateReplyRoutingLogic
    private let prompt: Prompt
    
    var promptTitle: String { return prompt.title }
    
    init(prompt: Prompt, router: CreateReplyRoutingLogic) {
        self.prompt = prompt
        self.router = router
    }
    
    func transform(input: Input) -> Output {
        let activityIndicator = ActivityIndicator()
        let errorTracker = ErrorTracker()
        let loading = activityIndicator.asDriver()
        let errors = errorTracker.asDriver()
        
        let inputIsValid = input.body.map { $0.count > 10 }
        let currentPrompt = Driver.of(prompt)

        let savedInput = Driver
            .combineLatest(currentPrompt, input.body.asDriver()) { (currentPrompt, replyBody) in
            return SavedReplyInput(body: replyBody, prompt: currentPrompt)
        }
  
        let promptDidUpdate = input.createTrigger
            .asObservable()
            .withLatestFrom(savedInput)
            .do(onNext: { input in self.router.toReplyOptions(with: input) })
            .mapToVoid()
        
        return Output(inputIsValid: inputIsValid,
                      currentPrompt: currentPrompt,
                      promptDidUpdate: promptDidUpdate,
                      loading: loading,
                      errors: errors)
    }
    
}
