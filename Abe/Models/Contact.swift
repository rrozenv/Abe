
import Foundation
import RealmSwift

class Contact: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var firstName: String = ""
    @objc dynamic var lastName: String = ""
    @objc dynamic var primaryNumber: String?
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
