
import Foundation

enum Visibility: String {
    case all
    case individualContacts
    case contacts
    case userReply
    case currentUserReplied
    case currentUserCreated
    
    func queryPredicateFor(currentUser: User) -> [NSPredicate] {
        switch self {
        case .all:
            return [NSPredicate(format: "visibility = %@", self.rawValue)]
        case .individualContacts:
            return [NSPredicate(format: "visibility = %@", self.rawValue), NSPredicate(format: "ANY visibleOnlyToContactNumbers.string = %@", currentUser.phoneNumber)]
        case .currentUserReplied:
            return [NSPredicate(format: "ANY replies.user.id = %@", currentUser.id)]
        case .currentUserCreated:
            return [NSPredicate(format: "user.id = %@", currentUser.id)]
        default: return []
        }
    }
}

extension Visibility: Equatable {
    static func ==(lhs: Visibility, rhs: Visibility) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}

extension Visibility: Hashable {
    var hashValue: Int {
        return rawValue.hashValue
    }
}
