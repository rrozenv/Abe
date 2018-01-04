
import Foundation
import RealmSwift
import RxSwift

enum ContactServiceError: Error {
    case saveAllFailed
}

struct ContactService {
    
    fileprivate func withRealm<T>(_ operation: String, action: (Realm) throws -> T) -> T? {
        do {
            let realm = try Realm()
            return try action(realm)
        } catch let err {
            print("Failed \(operation) realm with error: \(err)")
            return nil
        }
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
            return Observable.collection(from: contacts)
        }
        return result ?? .empty()
    }
    
}


