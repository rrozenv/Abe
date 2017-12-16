
import Foundation
import RealmSwift
import PromiseKit
import RxSwift
import RxCocoa

enum RealmError: Error {
    case saveFailed(String)
    case updateFailed(String)
    case createFailed(String?)
    case deleteObjectFailed(String)
    case deleteAllObjectsFailed
    
    var description: String {
        switch self {
        case .saveFailed(let description):
            return "Realm failed to save object: \(description)."
        case .updateFailed(let description):
            return "Realm failed to update object: \(description)"
        case .createFailed(let description):
            return "Realm failed to create object: \(String(describing: description))."
        case .deleteObjectFailed(let description):
            return "Realm failed to delete object: \(description)."
        case .deleteAllObjectsFailed:
            return "Realm failed to delete all objects."
        }
    }
}

public struct Sorted {
    var key: String
    var ascending: Bool = true
}

protocol RealmStorageFunctions {
    func save(object: Object) -> Promise<Void>
    func create<T: Object>(_ model: T.Type, value: [String: Any]?) -> Promise<T>
    func fetch<T: Object>(_ model: T.Type, predicate: NSPredicate?, sorted: Sorted?) -> Results<T>
    func deleteAll() -> Promise<Void>
    func delete(object: Object) -> Promise<Void>
}

class RealmInstance {
    
    private let realm: Realm
    
    required init(configuration: RealmConfig) {
        self.realm = try! Realm(configuration: configuration.configuration)
    }
    
    func create<T: Object>(_ model: T.Type, value: [String: Any]?) -> Observable<Void> {
        return Observable.create { [weak self] observer in
            do {
                try self?.realm.write {
                  self?.realm.create(model as Object.Type, value: value ?? [], update: false) as! T
                }
                observer.onNext(())
                observer.onCompleted()
            } catch {
                observer.onError(RealmError.createFailed("create failed"))
            }
            return Disposables.create()
        }
    }
    
    func save(object: Object) -> Observable<Void> {
        return Observable.create { [weak self] observer in
            do {
                try self?.realm.write {
                    self?.realm.add(object)
                }
                observer.onNext(())
                observer.onCompleted()
            } catch {
                observer.onError(RealmError.createFailed("create failed"))
            }
            return Disposables.create()
        }
    }
    

    func queryAll<T: Object>(_ model: T.Type) -> Observable<Results<T>> {
        return Observable.deferred {
            let realm = self.realm
            let objects = realm.objects(model)
            return Observable.collection(from: objects)
        }
    }
    
    func query<T: Object>(_ model: T.Type,
                          with predicate: NSPredicate,
                          sortDescriptors: [NSSortDescriptor] = []) -> Observable<Results<T>> {
        return Observable.deferred {
            let realm = self.realm
            let objects = realm.objects(T.self)
                .filter(predicate)
                //.sorted(by: sortDescriptors.map(SortDescriptor.init))
            return Observable.collection(from: objects)
        }
    }
    
    func update(block: @escaping () -> Void) -> Observable<Void> {
        return Observable.create { [weak self] observer in
            do {
                try self?.realm.write {
                    block()
                }
                observer.onNext(())
            } catch {
                observer.onError(error)
            }
            return Disposables.create()
        }
    }

//
//    func update(block: @escaping () -> Void) -> Promise<Void> {
//        return Promise { fullfill, reject in
//            do {
//                try realm.write {
//                    block()
//                }
//                fullfill(())
//            } catch {
//                reject(RealmError.updateFailed("Failed to update."))
//            }
//        }
//    }
//
//    func delete(object: Object) -> Promise<Void> {
//        return Promise { fullfill, reject in
//            do {
//                try realm.write {
//                    realm.delete(object)
//                }
//                fullfill(())
//            } catch {
//                reject(RealmError.deleteObjectFailed(object.description))
//            }
//        }
//    }
//
//    func deleteAll() -> Promise<Void> {
//        return Promise { fullfill, reject in
//            do {
//                try realm.write {
//                    realm.deleteAll()
//                }
//                fullfill(())
//            } catch {
//                reject(RealmError.deleteAllObjectsFailed)
//            }
//        }
//    }

}


