
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
    @objc dynamic var coins: Int = 0
    let contacts = List<Contact>()
    let registeredContacts = List<User>()
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
    
    func reply(to prompt: Prompt) -> PromptReply? {
        let predicate = NSPredicate(format: "promptId = %@", prompt.id)
        return self.replies.filter(predicate).first
    }
    
    func allNumbersFromContacts() -> [String] {
        return self.contacts.flatMap { $0.numbers }
    }
    
    func contactsWhoAreUsers(allUsers: Results<User>) -> [Contact] {
        return self.contacts.filter { (contact) -> Bool in
            return contact.numbers.contains(where: { (number) -> Bool in
                return allUsers.contains(where: { (user) -> Bool in
                    return user.phoneNumber == number
                })
            })
        }
    }
    
    func registeredUsersInContacts(allUsers: Results<User>) -> [User] {
        return self.contacts.flatMap { (contact) -> User? in
            guard let index = allUsers.index(where: { (user) -> Bool in
                return contact.numbers.contains(user.phoneNumber)
            }) else { return nil }
            return allUsers[index]
        }
    }
    
}




