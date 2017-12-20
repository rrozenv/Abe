
import Foundation
import RealmSwift
import RxSwift
import RxCocoa
import PromiseKit

class RealmInstance: RealmRepresentable {
    
    private let realm: Realm
    
    required init(configuration: RealmConfig) {
        self.realm = try! Realm(configuration: configuration.configuration)
    }
    
    func createT<T: Object>(_ model: T.Type, value: [String: Any], update: Bool) -> Promise<T> {
        return Promise { fullfill, reject in
            do {
                try realm.write {
                    let newObject = realm.create(model as Object.Type, value: value, update: update) as! T
                    fullfill(newObject)
                }
            } catch {
                reject(RealmError.createFailed(""))
            }
        }
    }
    
    func create<T: Object>(_ model: T.Type,
                           value: [String: Any],
                           update: Bool) -> Observable<Void> {
        return Observable.deferred {
            return self.realm.rx.create(model, value: value, update: update)
        }
    }
    
    func save(object: Object) -> Observable<Void> {
        return Observable.deferred {
            return self.realm.rx.save(object)
        }
    }
    
    func fetch<T: Object>(_ model: T.Type, primaryKey: String) -> Observable<T?> {
        return Observable.deferred {
            return self.realm.rx.fetch(model, primaryKey: primaryKey)
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
    
    func delete<T: Object>(_ object: T) -> Observable<Void> {
        return Observable.deferred {
            return self.realm.rx.delete(object)
        }
    }
    
    func update(block: @escaping () -> Void) -> Observable<Void> {
        return Observable.deferred {
            return self.realm.rx.update(block: block)
        }
    }
    
}

extension Reactive where Base: Realm {
    
    func create<T: Object>(_ model: T.Type, value: [String: Any], update: Bool) -> Observable<Void> {
        return Observable.create { observer in
            do {
                try self.base.write {
                    self.base.create(model, value: value, update: update)
                }
                observer.onNext(())
                observer.onCompleted()
            } catch {
                observer.onError(RealmError.createFailed("\(T.Type.self)"))
            }
            return Disposables.create()
        }
    }
    
    func fetch<T: Object>(_ model: T.Type, primaryKey: String) -> Observable<T?> {
        return Observable.create { observer in
            let object = self.base.object(ofType: model, forPrimaryKey: primaryKey)
            observer.onNext(object)
            observer.onCompleted()
            return Disposables.create()
        }
    }
    
    func save<R: Object>(_ object: R, update: Bool = true) -> Observable<Void> {
        return Observable.create { observer in
            do {
                try self.base.write {
                    self.base.add(object, update: update)
                }
                observer.onNext(())
                observer.onCompleted()
            } catch {
                observer.onError(error)
            }
            return Disposables.create()
        }
    }
    
    func update(block: @escaping () -> Void) -> Observable<Void> {
        return Observable.create { observer in
            do {
                try self.base.write {
                    block()
                }
                observer.onNext(())
            } catch {
                observer.onError(error)
            }
            return Disposables.create()
        }
    }
    
    func delete<R: Object>(_ object: R) -> Observable<Void> {
        return Observable.create { observer in
            do {
                try self.base.write {
                    self.base.delete(object)
                }
                observer.onNext(())
                observer.onCompleted()
            } catch {
                observer.onError(error)
            }
            return Disposables.create()
        }
    }
    
}


