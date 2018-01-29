
import Foundation

struct Constants {
    static let defaultSyncHost = "192.168.1.134"
    static let syncAuthURL = URL(string: "http://\(defaultSyncHost):9080")!
    static let syncServerURL = URL(string: "realm://\(defaultSyncHost):9080/")
    static let commonRealmURL = URL(string: "realm://\(defaultSyncHost):9080/CommonRealm")!
    static let privateRealmURL = URL(string: "realm://\(defaultSyncHost):9080/~/privateRealm")!
    static let temporaryRealmURL = URL(string: "realm://\(defaultSyncHost):9080/~/temporaryRealm")!
}
