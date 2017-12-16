
import Foundation
import RealmSwift

class User: Object {
    
    static var currentUserPredicate: NSPredicate {
        return NSPredicate(format: "id = %@", SyncUser.current!.identity!)
    }
    
    // MARK: - Properties
    @objc dynamic var id: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var email: String = ""
    //let replies = List<PromptReply>()
    
    // MARK: - Init
    convenience init(syncUser: SyncUser, name: String, email: String) {
        self.init()
        self.id = syncUser.identity ?? ""
        self.name = name
        self.email = email
    }
    
    // MARK: - Meta
    override static func primaryKey() -> String? {
        return "id"
    }
    
    var value: [String: Any] {
        return ["id": SyncUser.current!.identity!,
                "name": name,
                "email": email]
    }
    
}
