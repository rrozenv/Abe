
import Foundation
import RealmSwift
import RxSwift
import RxRealm
import Moya

enum PromptServiceError: Error {
    case creationFailed
    case updateFailed(Prompt)
    case deletionFailed(Prompt)
    case toggleFailed(Prompt)
}

protocol PromptServiceType {
    @discardableResult
    func createPrompt(title: String, body: String, imageUrl: String, webLink: WebLinkThumbnail?, user: User) -> Observable<Prompt>
    
    @discardableResult
    func delete(prompt: Prompt) -> Observable<Void>
    
    @discardableResult
    func update(prompt: Prompt, title: String, body: String) -> Observable<Prompt>
    
    @discardableResult
    func allPrompts() -> Observable<Results<Prompt>>
}

struct PromptService: PromptServiceType {
    
    fileprivate func withRealm<T>(_ operation: String, action: (Realm) throws -> T) -> T? {
        do {
            let realm = try Realm(configuration: RealmConfig.common.configuration)
            return try action(realm)
        } catch let err {
            print("Failed \(operation) realm with error: \(err)")
            return nil
        }
    }
    
    @discardableResult
    func createPrompt(title: String,
                      body: String,
                      imageUrl: String,
                      webLink: WebLinkThumbnail?,
                      user: User) -> Observable<Prompt> {
        let result = withRealm("creating") { realm -> Observable<Prompt> in
            let prompt = Prompt(title: title, body: body, imageUrl: imageUrl, webLink: webLink, user: user)
            try realm.write {
                realm.add(prompt)
            }
            return .just(prompt)
        }
        return result ?? .error(PromptServiceError.creationFailed)
    }
    
    func save(_ prompt: Prompt) -> Observable<Prompt> {
        let result = withRealm("creating") { realm -> Observable<Prompt> in
            try realm.write {
                realm.add(prompt)
            }
            return .just(prompt)
        }
        return result ?? .error(PromptServiceError.creationFailed)
    }
    
    @discardableResult
    func delete(prompt: Prompt) -> Observable<Void> {
        let result = withRealm("deleting") { realm-> Observable<Void> in
            try realm.write {
                realm.delete(prompt)
            }
            return .empty()
        }
        return result ?? .error(PromptServiceError.deletionFailed(prompt))
    }
    
    @discardableResult
    func update(prompt: Prompt,
                title: String,
                body: String) -> Observable<Prompt> {
        let result = withRealm("updating title") { realm -> Observable<Prompt> in
            try realm.write {
                prompt.title = title
                prompt.body = body
            }
            return .just(prompt)
        }
        return result ?? .error(PromptServiceError.updateFailed(prompt))
    }

    func allPrompts() -> Observable<Results<Prompt>> {
        let result = withRealm("getting prompts") { realm -> Observable<Results<Prompt>> in
            let tasks = realm.objects(Prompt.self)
            return Observable.collection(from: tasks)
        }
        return result ?? .empty()
    }
    
    func fetchPromptsWith(predicate: NSPredicate) -> Observable<[Prompt]> {
        let result = withRealm("getting replies") { realm -> Observable<[Prompt]> in
            let prompts = realm
                .objects(Prompt.self).sorted(byKeyPath: "createdAt",
                                             ascending: false)
                .filter(predicate)
                .toArray()

            return .just(prompts)
        }
        return result ?? .empty()
    }
    
    func fetchAll() -> Observable<[Prompt]> {
        let result = withRealm("getting replies") { realm -> Observable<[Prompt]> in
            let prompts = realm
                .objects(Prompt.self).sorted(byKeyPath: "createdAt",
                                             ascending: false)
                .toArray()
            
            return .just(prompts)
        }
        return result ?? .empty()
    }
    
    func changeSet() -> Observable<(AnyRealmCollection<Prompt>, RealmChangeset?)> {
        let result = withRealm("getting replies") { realm -> Observable<(AnyRealmCollection<Prompt>, RealmChangeset?)> in
            let objects = realm.objects(Prompt.self)
            return Observable.changeset(from: objects)
        }
        return result ?? .empty()
    }
    
    func changeSetFor(predicate: NSPredicate) -> Observable<(AnyRealmCollection<Prompt>, RealmChangeset?)> {
        let result = withRealm("getting replies") { realm -> Observable<(AnyRealmCollection<Prompt>, RealmChangeset?)> in
            let objects = realm.objects(Prompt.self).filter(predicate)
            return Observable.changeset(from: objects)
        }
        return result ?? .empty()
    }
    
}


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

    func fetchUserFor(key: String) -> Observable<User?> {
        print("sync key: \(key)")
        let result = withRealm("getting tasks") { realm -> Observable<User?> in
            let user = realm.objects(User.self)
                .filter(NSPredicate(format: "id = %@", key))
                .first
            return .just(user)
        }
        return result ?? .empty()
    }
    
    func fetchUser(key: String) -> User? {
        print(key)
        let realm = try! Realm(configuration: RealmConfig.common.configuration)
        let user = realm.objects(User.self)
            .filter("id == %@", key)
            .first
        return user
    }
    
    func fetchAll() -> Observable<Results<User>> {
        let result = withRealm("getting prompts") { realm -> Observable<Results<User>> in
            //let threadSafeRealm = try! Realm(configuration: RealmConfig.common.configuration)
            let users = realm.objects(User.self)
            return Observable.collection(from: users)
        }
        return result ?? .empty()
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

enum ReplyServiceError: Error {
    case creationFailed
    case updateFailed(PromptReply)
    case deletionFailed(PromptReply)
    case saveScoreFailed(PromptReply)
}

struct ReplyService {
    
    fileprivate func withRealm<T>(_ operation: String, action: (Realm) throws -> T) -> T? {
        do {
            let realm = try Realm(configuration: RealmConfig.common.configuration)
            return try action(realm)
        } catch let err {
            print("Failed \(operation) realm with error: \(err)")
            return nil
        }
    }
    
    @discardableResult
//    func createReply(title: String,
//                      body: String,
//                      user: User) -> Observable<Prompt> {
//        let result = withRealm("creating") { realm -> Observable<Prompt> in
//            let prompt = Prompt(title: title, body: body, user: user)
//            try realm.write {
//                realm.add(prompt)
//            }
//            return .just(prompt)
//        }
//        return result ?? .error(PromptServiceError.creationFailed)
//    }
    
    func saveReply(_ reply: PromptReply) -> Observable<PromptReply> {
        let result = withRealm("creating") { realm -> Observable<PromptReply> in
            try realm.write {
                realm.add(reply)
            }
            return .just(reply)
        }
        return result ?? .error(PromptServiceError.creationFailed)
    }
    
    func add(reply: PromptReply,
             to prompt: Prompt) -> Observable<(PromptReply, Prompt)> {
        let result = withRealm("updating title") { realm -> Observable<(PromptReply, Prompt)> in
            try realm.write {
                prompt.replies.append(reply)
            }
            return .just((reply, prompt))
        }
        return result ?? .error(ReplyServiceError.saveScoreFailed(reply))
    }
    
    func add(reply: PromptReply,
             to user: User) -> Observable<(PromptReply, User)> {
        let result = withRealm("updating title") { realm -> Observable<(PromptReply, User)> in
            try realm.write {
                user.replies.append(reply)
            }
            return .just((reply, user))
        }
        return result ?? .error(ReplyServiceError.saveScoreFailed(reply))
    }
    
    @discardableResult
    func delete(prompt: Prompt) -> Observable<Void> {
        let result = withRealm("deleting") { realm-> Observable<Void> in
            try realm.write {
                realm.delete(prompt)
            }
            return .empty()
        }
        return result ?? .error(PromptServiceError.deletionFailed(prompt))
    }
    
    @discardableResult
    func updateAuthorCoinsFor(reply: PromptReply,
                              coins: Int) -> Observable<PromptReply> {
        let result = withRealm("updating title") { realm -> Observable<PromptReply> in
            try realm.write {
                reply.user?.coins += coins
            }
            return .just(reply)
        }
        return result ?? .error(ReplyServiceError.saveScoreFailed(reply))
    }
    
    func saveScore(reply: PromptReply,
                   score: ReplyScore) -> Observable<(reply: PromptReply, score: ReplyScore)> {
        let result = withRealm("updating title") { realm -> Observable<(reply: PromptReply, score: ReplyScore)> in
            try realm.write {
                reply.scores.append(score)
            }
            return .just((reply, score))
        }
        return result ?? .error(ReplyServiceError.saveScoreFailed(reply))
    }
    
    func fetchRepliesWith(predicate: NSPredicate) -> Observable<[PromptReply]> {
        let result = withRealm("getting replies") { realm -> Observable<[PromptReply]> in
            let replies = realm
                .objects(PromptReply.self)
                .filter(predicate)
                .toArray()
            return .just(replies)
        }
        return result ?? .empty()
    }
    
}


