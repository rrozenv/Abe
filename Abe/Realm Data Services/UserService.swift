
import Foundation
import RxSwift
import RealmSwift

struct UserService {
    
    fileprivate func withRealm<T>(_ operation: String, action: (Realm) throws -> T) -> T? {
        do {
            let realm = try Realm(configuration: RealmConfig.common.configuration)
            return try action(realm)
        } catch let err {
            print("Failed \(operation) realm with error: \(err)")
            return nil
        }
    }
    
    func fetchUserFor(key: String) -> Observable<User?> {
        let result = withRealm("getting user") { realm -> Observable<User?> in
            print("sync identity: \(key)")
            let user = realm.objects(User.self)
                .filter { $0.id == key }
                .first
            return .just(user)
        }
        return result ?? .empty()
    }
    
    func fetchAll() -> Observable<Results<User>> {
        let result = withRealm("getting users") { realm -> Observable<Results<User>> in
            let users = realm.objects(User.self)
            return Observable.collection(from: users)
        }
        return result ?? .empty()
    }
    
    func createUser(syncUser: SyncUser,
                    name: String,
                    email: String,
                    phoneNumber: String) -> Observable<User> {
        let result = withRealm("creating") { realm -> Observable<User> in
            let user = User(syncUserId: syncUser.identity!,
                            name: name,
                            phoneNumber: phoneNumber)
            try realm.write {
                realm.add(user)
            }
            return .just(user)
        }
        return result ?? .error(PromptServiceError.creationFailed)
    }
    
    
    
    func fetchUser(key: String) -> User? {
        print(key)
        let realm = try! Realm(configuration: RealmConfig.common.configuration)
        let user = realm.object(ofType: User.self, forPrimaryKey: key)
        //            .filter("id == %@", key)
        //            .first
        return user
    }
    
    func update(imageData: Data, for user: User) -> Observable<User> {
        let result = withRealm("updating title") { realm -> Observable<User> in
            try realm.write {
                user.avatarImageData = imageData
            }
            return .just(user)
        }
        return result ?? .error(ReplyServiceError.creationFailed)
    }
    
    func add(userFriends: [User],
             to currentUser: User) -> Observable<([User], User)> {
        let result = withRealm("updating title") { realm -> Observable<([User], User)> in
            //            let threadSafeRealm = try! Realm(configuration: RealmConfig.common.configuration)
            //            let user = threadSafeRealm.object(ofType: User.self, forPrimaryKey: currentUser.id)
            try realm.write {
                currentUser.registeredContacts.append(objectsIn: userFriends)
            }
            return .just((userFriends, currentUser))
        }
        return result ?? .error(ReplyServiceError.creationFailed)
    }
    
    func updateCoinsFor(user: User, wager: Int, shouldAdd: Bool) -> Observable<(user: User, wager: Int, isCorrect: Bool)> {
        let result = withRealm("updating title") { realm -> Observable<(user: User, wager: Int, isCorrect: Bool)> in
            try realm.write {
                if shouldAdd { user.coins += wager }
                else { user.coins -= wager }
            }
            return .just((user, wager, shouldAdd))
        }
        return result ?? .error(ReplyServiceError.creationFailed)
    }
    
    
    
    //    func registedContactsFor(user: User, allUsers: Results<User>) -> Observable<[User]> {
    //        return self.contacts.flatMap { (contact) -> User? in
    //            guard let index = allUsers.index(where: { (user) -> Bool in
    //                return contact.numbers.contains(user.phoneNumber)
    //            }) else { return nil }
    //            return allUsers[index]
    //        }
    //    }
    
}
