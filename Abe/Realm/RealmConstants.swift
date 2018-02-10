
import Foundation

struct Constants {
    static let defaultSyncHost = "172.31.99.172"
    static let syncAuthURL = URL(string: "http://\(defaultSyncHost):9080")!
    static let syncServerURL = URL(string: "realm://\(defaultSyncHost):9080/")
    static let commonRealmURL = URL(string: "realm://\(defaultSyncHost):9080/CommonRealm")!
    static let privateRealmURL = URL(string: "realm://\(defaultSyncHost):9080/~/privateRealm")!
    static let temporaryRealmURL = URL(string: "realm://\(defaultSyncHost):9080/~/temporaryRealm")!
}
