
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
    let contacts = List<Contact>()
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

class Contact: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var firstName: String = ""
    @objc dynamic var lastName: String = ""
    let numbers = List<String>()
    
    convenience init(id: String, first: String, last: String, numbers: [String]) {
        self.init()
        self.id = id
        self.firstName = first
        self.lastName = last
        numbers.forEach { self.numbers.append($0) }
    }
    // MARK: - Meta
    override static func primaryKey() -> String? {
        return "id"
    }
    
}
