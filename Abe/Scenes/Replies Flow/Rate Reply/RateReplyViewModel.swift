
import Foundation
import RxSwift
import RxCocoa

struct RatingScore {
    let value: Int
    var isSelected: Bool
}

protocol RateReplyViewModelInputs {
    var viewWillAppearInput: AnyObserver<Void> { get }
    var selectedScoreInput: AnyObserver<RatingScore> { get }
}

protocol RateReplyViewModelOutputs {
    var ratingScores: Driver<[RatingScore]> { get }
    var previousAndCurrentScore: Observable<(previous: RatingScore, current: RatingScore)> { get }
}

protocol RateReplyViewModelType {
    var inputs: RateReplyViewModelInputs { get }
    var outputs: RateReplyViewModelOutputs { get }
}

final class RateReplyViewModel: RateReplyViewModelInputs, RateReplyViewModelOutputs, RateReplyViewModelType {
    
    let disposeBag = DisposeBag()
    
    //MARK: - Inputs
    var inputs: RateReplyViewModelInputs { return self }
    let viewWillAppearInput: AnyObserver<Void>
    let selectedScoreInput: AnyObserver<RatingScore>
    
    //MARK: - Outputs
    var outputs: RateReplyViewModelOutputs { return self }
    let ratingScores: Driver<[RatingScore]>
    let previousAndCurrentScore: Observable<(previous: RatingScore, current: RatingScore)>
    
    //MARK: - Init
    init(reply: PromptReply) {
   
        //MARK: - Subjects
        let _viewWillAppearInput = PublishSubject<Void>()
        let _selectedScoreInput = PublishSubject<RatingScore>()
        
        //MARK: - Observers
        self.viewWillAppearInput = _viewWillAppearInput.asObserver()
        self.selectedScoreInput = _selectedScoreInput.asObserver()
        
        //MARK: - First Level Observables
        let viewWillAppearObservable = _viewWillAppearInput.asObservable()
        let selectedScoreObservable = _selectedScoreInput.asObservable()
            .startWith(RatingScore(value: 0, isSelected: false))
        
        //MARK: - Outputs
        self.ratingScores = viewWillAppearObservable
            .map { _ in
                return [1, 2, 3, 4, 5].map { RatingScore(value: $0, isSelected: false) }
            }
            .asDriverOnErrorJustComplete()
        
        self.previousAndCurrentScore = Observable
            .zip(selectedScoreObservable, selectedScoreObservable.skip(1)) {
                (previous: $0, current: $1)
        }
        
        //MARK: - Routing
//        doneTappedObservable
//            .do(onNext: router.toMainCreateReplyInput)
//            .subscribe()
//            .disposed(by: disposeBag)
        
    }
    
}
