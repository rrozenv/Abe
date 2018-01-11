
import Foundation
import UIKit

struct ScoreCellViewModel {
    let value: Int
    let reply: PromptReply
    let userDidReply: Bool
    let placeholderImage: UIImage
    let userScore: ReplyScore?
    let percentage: String
}


