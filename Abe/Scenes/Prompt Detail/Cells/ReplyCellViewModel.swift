
import Foundation
import RxSwift
import RxCocoa
import RealmSwift

struct ScoreCellViewModel {
    let userDidReply: Bool
    let placeholderImage: UIImage
    let userScore: ReplyScore?
}

struct ReplyCellViewModel {
    
    struct Input {
        let reply: PromptReply
    }
    
    struct Output {
        //let userName: Driver<String>
        let info: Driver<(String, String)>
        let scoreCellViewModels: Driver<[ScoreCellViewModel]>
    }
    
    private let commonRealm: RealmInstance
    
    init(commonRealm: RealmInstance) {
        self.commonRealm = commonRealm
    }

    func transform(input: Input) -> Output {
        let _user = self.commonRealm
            .fetch(User.self, primaryKey: SyncUser.current!.identity!)
            .unwrap()
            .asDriverOnErrorJustComplete()
        
        let _reply = Driver.of(input.reply)
        let info = _reply.map { ($0.user!.name, $0.body) }
//        let userName = _reply.map { $0.user!.name }
//        let body = _reply.map { $0.body }
        
        let scores = Driver
            .combineLatest(_user, _reply) { (user: $0, reply: $1) }
        
        let userReplyScore = scores
            .map { (inputs) -> ReplyScore? in
                if let index = inputs.reply.scores.index(where: { (score) -> Bool in
                    score.id == inputs.user.id
                }) {
                  return inputs.reply.scores[index]
                } else {
                  return nil
                }
            }
        
        let scoreViewModels = Observable
            .of(#imageLiteral(resourceName: "IC_Score_One_Unselected"), #imageLiteral(resourceName: "IC_Score_Two_Unselected"), #imageLiteral(resourceName: "IC_Score_Three_Unselected"), #imageLiteral(resourceName: "IC_Score_Four_Unselected"), #imageLiteral(resourceName: "IC_Score_Five_Unselected"))
            .toArray()
            .withLatestFrom(userReplyScore) { (placeholders, userScore) -> [ScoreCellViewModel] in
                return placeholders.map { (placeholder) -> ScoreCellViewModel in
                    return ScoreCellViewModel(userDidReply: (userScore != nil) ? true : false,
                        placeholderImage: placeholder,
                        userScore: userScore)
                }
            }
            .asDriverOnErrorJustComplete()
       
        return Output(info: info,
                      scoreCellViewModels: scoreViewModels)
    }

}

extension ReplyCellViewModel {
    
    enum Score {
        case one(UIImage, String)
        case two(UIImage, String)
        case three(UIImage, String)
        case four(UIImage, String)
        case five(UIImage, String)
        
        var getImage: UIImage {
            switch self {
            case .one(let image, _):
                return image
            case .two(let image, _):
                return image
            case .three(let image, _):
                return image
            case .four(let image, _):
                return image
            case .five(let image, _):
                return image
            }
        }
        
        var getScore: String {
            switch self {
            case .one(_, let score):
                return score
            case .two(_, let score):
                return score
            case .three(_, let score):
                return score
            case .four(_, let score):
                return score
            case .five(_, let score):
                return score
            }
        }
        
        static func createScores() -> [Score] {
            return [Score.one(#imageLiteral(resourceName: "IC_Score_One_Unselected"), "1"), Score.two(#imageLiteral(resourceName: "IC_Score_Two_Unselected"), "2"), Score.three(#imageLiteral(resourceName: "IC_Score_Three_Unselected"), "3"), Score.four(#imageLiteral(resourceName: "IC_Score_Four_Unselected"), "4"), Score.five(#imageLiteral(resourceName: "IC_Score_Five_Unselected"), "5")]
        }
    }
    
}
