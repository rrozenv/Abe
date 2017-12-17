
import Foundation
import RealmSwift
import RxSwift
import RxCocoa

enum RealmError: Error {
    case saveFailed(String)
    case updateFailed(String)
    case createFailed(String)
    case deleteObjectFailed(String)
    case deleteAllObjectsFailed
    
    var description: String {
        switch self {
        case .saveFailed(let type):
            return "Realm failed to save object of type: \(type)."
        case .updateFailed(let type):
            return "Realm failed to update object of type: \(type)"
        case .createFailed(let type):
            return "Realm failed to create objecto of type: \(type)."
        case .deleteObjectFailed(let type):
            return "Realm failed to delete object: \(type)."
        case .deleteAllObjectsFailed:
            return "Realm failed to delete all objects."
        }
    }
}

class RealmInstance: RealmRepresentable {
    
    private let realm: Realm
    
    required init(configuration: RealmConfig) {
        self.realm = try! Realm(configuration: configuration.configuration)
    }
    
    func create<T: Object>(_ model: T.Type, value: [String: Any]) -> Observable<Void> {
        return Observable.create { [weak self] observer in
            do {
                try self?.realm.write {
                  self?.realm.create(model, value: value, update: false)
                }
                observer.onNext(())
                observer.onCompleted()
            } catch {
                observer.onError(RealmError.createFailed("\(T.Type.self)"))
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
                observer.onError(RealmError.saveFailed("\(object.description)"))
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

    func delete(object: Object) -> Observable<Void> {
        return Observable.create { [weak self] observer in
            do {
                try self?.realm.write {
                    self?.realm.delete(object)
                }
                observer.onNext(())
                observer.onCompleted()
            } catch {
                observer.onError(RealmError.deleteObjectFailed("\(object.description)"))
            }
            return Disposables.create()
        }
    }

    func deleteAll() -> Observable<Void> {
        return Observable.create { [weak self] observer in
            do {
                try self?.realm.write {
                    self?.realm.deleteAll()
                }
                observer.onNext(())
                observer.onCompleted()
            } catch {
                observer.onError(RealmError.deleteAllObjectsFailed)
            }
            return Disposables.create()
        }
    }

}


