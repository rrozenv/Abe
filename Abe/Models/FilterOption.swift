
import Foundation

enum FilterOption: Int {
    case locked = 1
    case unlocked = 2
    case myReply = 3
    
    func publicRepliesByCurrentUsersFriendsPredicate(currentUser: User) -> [NSPredicate] {
        switch self {
        case .locked:
            return
                [
                    NSPredicate(format: "visibility = %@ AND ANY visibleOnlyToContactNumbers.string = %@", argumentArray: [Visibility.individualContacts.rawValue, currentUser.phoneNumber]),
                    NSPredicate(format: "visibility = %@", Visibility.all.rawValue),
                    NSPredicate(format: "ANY scores.user.id != %@", currentUser.id)
                    //NSPredicate(format: "user.id IN %@", currentUser.registeredContacts.flatMap { $0.id })
                ]
        case .unlocked:
            return [
                NSPredicate(format: "ANY scores.user.id = %@", currentUser.id)
            ]
        case .myReply:
            return [
                NSPredicate(format: "ANY user.id = %@", currentUser.id)
            ]
        }
    }
    
    func privateRepliesByCurrentUsersFriends(currentUser: User) -> [NSPredicate] {
        switch self {
        case .locked:
            return
                [
                    NSPredicate(format: "visibility = %@", Visibility.individualContacts.rawValue),
                    NSPredicate(format: "ANY scores.user.id != %@", currentUser.id),
                    NSPredicate(format: "ANY visibleOnlyToPhoneNumbers.string = %@", currentUser.phoneNumber)
            ]
        case .unlocked:
            return [
                NSPredicate(format: "ANY scores.user.id = %@", currentUser.id)
            ]
        case .myReply:
            return [
                NSPredicate(format: "ANY user.id = %@", currentUser.id)
            ]
        }
    }
    
    func publicRepliesByNotCurrentUsersFriends(currentUser: User) -> [NSPredicate] {
        switch self {
        case .locked:
            return
                [
                    NSPredicate(format: "visibility = %@", Visibility.all.rawValue),
                    NSPredicate(format: "ANY scores.user.id != %@", currentUser.id),
                    NSPredicate(format: "NOT (user.id IN) %@", currentUser.registeredContacts.flatMap { $0.id })
            ]
        case .unlocked:
            return [
                NSPredicate(format: "ANY scores.user.id = %@", currentUser.id)
            ]
        case .myReply:
            return [
                NSPredicate(format: "ANY user.id = %@", currentUser.id)
            ]
        }
    }
    
}
