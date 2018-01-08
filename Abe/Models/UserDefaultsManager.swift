
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
    
    class func saveSignUpName(name: (String, String)) {
        var dict = [String: Any]()
        dict["first"] = name.0
        dict["last"] = name.1
        defaults.set(dict, forKey: "signUpInfo")
    }
    
    class func userName() -> (first: String, last: String)? {
        guard let dict = defaults.value(forKey: "signUpInfo") as? [String: Any],
            let first = dict["first"] as? String,
            let last = dict["last"] as? String
            else { return nil }
        return (first, last)
    }
    
}
