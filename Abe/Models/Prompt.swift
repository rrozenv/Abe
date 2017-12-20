
import Foundation
import RealmSwift
import RxSwift

class Prompt: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var body: String = ""
    @objc dynamic var imageURL: String = ""
    @objc dynamic var user: User?
    @objc dynamic var createdAt = Date()
    let replies = List<PromptReply>()
    
    override static func primaryKey() -> String? {
        return "id"
    }

    convenience init(id: String,
                     title: String,
                     body: String,
                     user: User) {
        self.init()
        self.id = id
        self.title = title
        self.body = body
        self.user = user
        //self.imageURL = imageURL
    }
    
    var value: [String: Any] {
        return ["id": UUID().uuidString,
                "title": title,
                "body": body]
    }
    
}








