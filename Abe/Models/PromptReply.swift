
import Foundation
import RealmSwift

class PromptReply: Object {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var user: User?
    @objc dynamic var promptId: String = ""
    @objc dynamic var body: String = ""
    @objc dynamic var visibility: String = "all"
    @objc dynamic var createdAt = Date()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    convenience init(user: User,
                     promptId: String,
                     body: String,
                     visibility: String = "all") {
        self.init()
        self.user = user
        self.promptId = promptId
        self.body = body
        self.visibility = visibility
    }
    
    var value: [String: Any] {
        return ["id": UUID().uuidString,
                "promptId": promptId,
                "visibility": visibility,
                "body": body]
    }
    
}
