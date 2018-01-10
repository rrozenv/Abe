
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
    @objc dynamic var phoneNumber: String = ""
    let contacts = List<Contact>()
    let prompts = List<Prompt>()
    let replies = List<PromptReply>()
    
    // MARK: - Init
    convenience init(syncUser: SyncUser,
                     name: String,
                     email: String) {
        self.init()
        self.id = syncUser.identity ?? ""
        self.name = name
        self.email = email
        self.phoneNumber = "555-478-7672"
    }
    
    convenience init(syncUserId: String,
                     name: String,
                     phoneNumber: String) {
        self.init()
        self.id = syncUserId
        self.name = name
        self.phoneNumber = phoneNumber
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
    
    func didReply(to prompt: Prompt) -> Bool {
        let predicate = NSPredicate(format: "promptId = %@", prompt.id)
        let userReplies = self.replies.filter(predicate)
        return userReplies.count > 0
    }
    
    func allNumbersFromContacts() -> [String] {
        return self.contacts.flatMap { $0.numbers }
    }
    
}


