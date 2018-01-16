
import Foundation
import RealmSwift
import RxSwift

final class Prompt: Object {
    @objc dynamic var id: String = NSUUID().uuidString
    @objc dynamic var title: String = ""
    @objc dynamic var body: String = ""
    @objc dynamic var imageURL: String = ""
    @objc dynamic var createdAt = Date()
    @objc dynamic var user: User?
    let replies = List<PromptReply>()
    
    override static func primaryKey() -> String? {
        return "id"
    }

    convenience init(title: String,
                     body: String,
                     imageUrl: String,
                     user: User) {
        self.init()
        self.title = title
        self.body = body
        self.user = user
        self.imageURL = imageUrl
    }
}








