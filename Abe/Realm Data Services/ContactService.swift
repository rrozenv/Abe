
import Foundation
import RealmSwift
import RxSwift

enum ContactServiceError: Error {
    case saveAllFailed
}

struct ContactService {
    
    private func withRealm<T>(_ operation: String, action: (Realm) throws -> T) -> T? {
        do {
            let realm = try Realm()
            return try action(realm)
        } catch let err {
            print("Failed \(operation) realm with error: \(err)")
            return nil
        }
    }
    
    private func withCommonRealm<T>(_ operation: String, action: (Realm) throws -> T) -> T? {
        do {
            let realm = try Realm(configuration: RealmConfig.common.configuration)
            return try action(realm)
        } catch let err {
            print("Failed \(operation) realm with error: \(err)")
            return nil
        }
    }
    
    func add(contacts: [Contact],
             to user: User) -> Observable<User> {
        let result = withCommonRealm("updating title") { realm -> Observable<User>  in
            try realm.write {
                user.contacts.append(objectsIn: contacts)
            }
            return .just(user)
        }
        return result ?? .error(ContactServiceError.saveAllFailed)
    }
    
    func saveAll(_ contacts: [Contact]) -> Observable<[Contact]> {
        let result = withRealm("creating") { realm -> Observable<[Contact]> in
            try realm.write {
                realm.add(contacts, update: true)
            }
            return .just(contacts)
        }
        return result ?? .error(ContactServiceError.saveAllFailed)
    }
    
    func fetchAll() -> Observable<Results<Contact>> {
        let result = withRealm("getting prompts") { realm -> Observable<Results<Contact>> in
            let contacts = realm.objects(Contact.self)
            return .just(contacts)
        }
        return result ?? .empty()
    }
    
    func fetchWith(predicate: NSPredicate) -> Observable<Results<Contact>> {
        let result = withRealm("getting replies") { realm -> Observable<Results<Contact>> in
            let contacts = realm
                .objects(Contact.self)
                .filter(predicate)
            
            return .just(contacts)
        }
        return result ?? .empty()
    }
    
}


