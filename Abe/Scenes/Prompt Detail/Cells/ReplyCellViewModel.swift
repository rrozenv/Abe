
import Foundation
import RxSwift
import RxCocoa
import RealmSwift

struct ScoreCellViewModel {
    let value: Int
    let reply: PromptReply
    var userDidReply: Bool
    let placeholderImage: UIImage
    let userScore: ReplyScore?
    let percentage: String
}


