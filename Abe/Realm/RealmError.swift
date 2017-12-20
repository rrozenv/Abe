
import Foundation

enum RealmError: Error {
    case saveFailed(String)
    case updateFailed(String)
    case createFailed(String)
    case deleteObjectFailed(String)
    case deleteAllObjectsFailed
    
    var description: String {
        switch self {
        case .saveFailed(let type):
            return "Realm failed to save object of type: \(type)."
        case .updateFailed(let type):
            return "Realm failed to update object of type: \(type)"
        case .createFailed(let type):
            return "Realm failed to create objecto of type: \(type)."
        case .deleteObjectFailed(let type):
            return "Realm failed to delete object: \(type)."
        case .deleteAllObjectsFailed:
            return "Realm failed to delete all objects."
        }
    }
}
