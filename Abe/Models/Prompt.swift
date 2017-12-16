
import Foundation
import RealmSwift

class Prompt: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var body: String = ""
    @objc dynamic var imageURL: String = ""
    @objc dynamic var createdAt = Date()
    
    override static func primaryKey() -> String? {
        return "id"
    }

    convenience init(title: String, body: String) {
        self.init()
        self.title = title
        self.body = body
        //self.imageURL = imageURL
    }
    
    var value: [String: Any] {
        return ["id": UUID().uuidString,
                "title": title,
                "body": body]
    }
    
}




