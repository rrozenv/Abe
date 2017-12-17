
import Foundation
import RealmSwift

class PromptReply: Object {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var userId: String = ""
    @objc dynamic var userName: String = ""
    @objc dynamic var promptId: String = ""
    @objc dynamic var body: String = ""
    @objc dynamic var visibility: String = "all"
    @objc dynamic var createdAt = Date()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    convenience init(userId: String, userName: String, promptId: String, body: String, visibility: String = "all") {
        self.init()
        self.userId = userId
        self.userName = userName
        self.promptId = promptId
        self.body = body
        self.visibility = visibility
    }
    
    var value: [String: Any] {
        return ["id": UUID().uuidString,
                "userId": userId,
                "userName": userName,
                "promptId": promptId,
                "visibility": visibility,
                "body": body]
    }
    
}
