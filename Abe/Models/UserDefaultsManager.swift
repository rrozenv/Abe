
import Foundation

struct UserInfo {
    let id: String
    let name: String
    let phoneNumber: String
}

final class UserDefaultsManager {
  
    private static let defaults = UserDefaults.standard

    class func saveUserInfo(_ user: User) {
        var dict = [String: Any]()
        dict["id"] = user.id
        dict["userName"] = user.name
        dict["phoneNumber"] = user.phoneNumber
        defaults.set(dict, forKey: "user")
    }
    
    class func userInfo() -> UserInfo? {
        guard let dict = defaults.value(forKey: "user") as? [String: Any],
              let id = dict["id"] as? String,
              let name = dict["userName"] as? String,
              let phoneNumber = dict["phoneNumber"] as? String
              else { return nil }
        return UserInfo(id: id, name: name, phoneNumber: phoneNumber)
    }
    
}
