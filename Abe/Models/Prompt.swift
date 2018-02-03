
import Foundation
import RealmSwift
import RxSwift

class StringObject: Object {
    @objc dynamic var string = ""
    
    convenience init(_ string: String) {
        self.init()
        self.string = string
    }
}

final class Prompt: Object {
    @objc dynamic var id: String = NSUUID().uuidString
    @objc dynamic var title: String = ""
    @objc dynamic var body: String = ""
    @objc dynamic var visibility: String = "all"
    @objc dynamic var imageURL: String = ""
    @objc dynamic var createdAt = Date()
    @objc dynamic var user: User?
    @objc dynamic var webLinkThumbnail: WebLinkThumbnail?
    let visibleOnlyToContactNumbers = List<StringObject>()
    let visibleOnlyToUserIds = List<String>()
    let replies = List<PromptReply>()
    
    override static func primaryKey() -> String? {
        return "id"
    }

    convenience init(title: String,
                     body: String,
                     imageUrl: String,
                     webLink: WebLinkThumbnail?,
                     user: User) {
        self.init()
        self.title = title
        self.body = body
        self.user = user
        self.imageURL = imageUrl
        self.webLinkThumbnail = webLink
    }
    
    func isViewableBy(currentUser: User) -> Bool {
        return visibleOnlyToContactNumbers.contains(StringObject(currentUser.id)) || self.user?.id == currentUser.id
    }
}








