
import Foundation
import RealmSwift
import PromiseKit
import RxSwift
import RxCocoa

final class RealmAuth {
    
    class func fetchCurrentSyncUser() -> SyncUser? {
        guard let syncUser = SyncUser.current else { return nil }
        return syncUser
    }
    
    class func fetchSyncUser() -> Observable<SyncUser?> {
        return Observable.create { (observer) in
            if let syncUser = SyncUser.current {
                observer.onNext(syncUser)
            } else {
                observer.onNext(nil)
            }
            observer.onCompleted()
            return Disposables.create()
        }
    }
    
    class func resetDefaultRealm() {
        guard let user = SyncUser.current else { return }
        user.logOut()
    }
    
    class func login(email: String, password: String) -> Observable<SyncUser> {
        let credentials = SyncCredentials.usernamePassword(username: email, password: password, register: false)
        return Observable.create { observer in
            SyncUser.logIn(with: credentials, server: Constants.syncAuthURL, onCompletion: { (syncUser, error) in
                if let user = syncUser {
                    observer.onNext(user)
                    observer.onCompleted()
                }
                if let error = error {
                    observer.onError(error)
                }
            })
            return Disposables.create()
        }
    }
    
    class func authorize(email: String, password: String, register: Bool) -> Observable<SyncUser> {
        let credentials = SyncCredentials.usernamePassword(username: email, password: password, register: register)
        return Observable.create { observer in
            SyncUser.logIn(with: credentials, server: Constants.syncAuthURL, onCompletion: { (syncUser, error) in
                if let user = syncUser {
                    observer.onNext(user)
                    observer.onCompleted()
                }
                if let error = error {
                    observer.onError(error)
                }
            })
            return Disposables.create()
        }
    }
    
    class func initializeCommonRealm(completion: @escaping (Bool) -> Void) {
        Realm.asyncOpen(configuration: RealmConfig.common.configuration, callback: { (realm, error) in
            if let realm = realm {
                if SyncUser.current?.isAdmin == true {
                    self.setPermissionForRealm(realm, accessLevel: .write, personID: "*")
                }
                completion(true)
            }
            if let error = error {
                print(error.localizedDescription)
                completion(false)
            }
        })
    }
    
    class func setPermissionForRealm(_ realm: Realm?, accessLevel: SyncAccessLevel, personID: String) {
        if let realm = realm {
            let perm = SyncPermission(realmPath: realm.configuration.syncConfiguration!.realmURL.path,
                                      identity: personID,
                                      accessLevel: accessLevel)
            SyncUser.current?.apply(perm) { error in
                if let error = error {
                    print("Error when attempting to set permissions: \(error.localizedDescription)")
                    return
                } else {
                    print("Permissions successfully set")
                }
            }
        }
    }
    
}


