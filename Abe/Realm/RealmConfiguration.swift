
import Foundation
import RealmSwift

enum RealmConfig {
    
    case common
    case secret
    case temporary
    
    var configuration: Realm.Configuration {
        switch self {
        case .common:
            return RealmConfig.commonRealmConfig(user: SyncUser.current!)
        case .secret:
            return RealmConfig.privateRealmConfig(user: SyncUser.current!)
        case .temporary:
            return RealmConfig.temporaryRealmConfig(user: SyncUser.current!)
        }
    }
    
    private static func commonRealmConfig(user: SyncUser) -> Realm.Configuration  {
        let config = Realm.Configuration(syncConfiguration: SyncConfiguration(user: SyncUser.current!, realmURL: Constants.commonRealmURL), objectTypes: [Prompt.self, User.self, PromptReply.self])
        return config
    }
    
    private static func privateRealmConfig(user: SyncUser) -> Realm.Configuration  {
        let config = Realm.Configuration(syncConfiguration: SyncConfiguration(user: SyncUser.current!, realmURL: Constants.privateRealmURL), objectTypes: [])
        return config
    }
    
    private static func temporaryRealmConfig(user: SyncUser) -> Realm.Configuration  {
        let config = Realm.Configuration(syncConfiguration: SyncConfiguration(user: SyncUser.current!, realmURL: Constants.temporaryRealmURL), objectTypes: [])
        return config
    }
    
}
