
import Foundation
import RealmSwift
import RxSwift
import RxRealm

enum PromptServiceError: Error {
    case creationFailed
    case updateFailed(Prompt)
    case deletionFailed(Prompt)
    case toggleFailed(Prompt)
}

protocol PromptServiceType {
    @discardableResult
    func createPrompt(title: String, body: String, user: User) -> Observable<Prompt>
    
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
                      user: User) -> Observable<Prompt> {
        let result = withRealm("creating") { realm -> Observable<Prompt> in
            let prompt = Prompt(title: title, body: body, user: user)
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

    func fetchUserFor(key: String) -> Observable<User> {
        let result = withRealm("getting tasks") { realm -> Observable<User> in
            guard let user = realm.object(ofType: User.self, forPrimaryKey: key) else { return .empty() }
            return .just(user)
        }
        return result ?? .empty()
    }
    
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
    func createReply(title: String,
                      body: String,
                      user: User) -> Observable<Prompt> {
        let result = withRealm("creating") { realm -> Observable<Prompt> in
            let prompt = Prompt(title: title, body: body, user: user)
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
    func saveScore(reply: PromptReply,
                   score: ReplyScore) -> Observable<(PromptReply, ReplyScore)> {
        let result = withRealm("updating title") { realm -> Observable<(PromptReply, ReplyScore)> in
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
