
import Foundation
import RealmSwift
import RxSwift
import RxCocoa
import PromiseKit
import RxRealm

class RealmInstance {
    
    private let realm: Realm
    private let config: Realm.Configuration
    
    required init(configuration: RealmConfig) {
        self.config = configuration.configuration
        self.realm = try! Realm(configuration: configuration.configuration)
    }
    
    func create<T: Object>(_ model: T.Type,
                           value: [String: Any],
                           update: Bool) -> Observable<Void> {
        return Observable.deferred {
            return self.realm.rx.create(model, value: value, update: update)
        }
    }
    
    func save<T: Object>(object: T) -> Observable<T> {
        return self.realm.rx.save(object)
    }
    
    func saveT<T: Object>(object: T) -> Observable<T> {
        return Observable.create { observer in
            do {
                try self.realm.write {
                    self.realm.add(object)
                }
                observer.onNext(object)
                observer.onCompleted()
            } catch {
                observer.onError(error)
            }
            return Disposables.create()
        }
    }
    
    func save(objects: [Object]) -> Observable<Void> {
        return Observable.deferred {
            return self.realm.rx.save(objects)
        }
    }
    
    
    func fetch<T: Object>(_ model: T.Type, primaryKey: String) -> Observable<T?> {
        return Observable.deferred {
            return self.realm.rx.fetch(model, primaryKey: primaryKey)
        }
    }
    
    func fetchAll<T: Object>(_ model: T.Type) -> Observable<(AnyRealmCollection<T>, RealmChangeset?)> {
        return Observable.deferred {
            let realm = self.realm
            let objects = realm.objects(model)
            return Observable.changeset(from: objects)
        }
    }
    
    func fetch<T: Object>(_ model: T.Type,
                          with predicate: NSPredicate,
                          sortDescriptors: [NSSortDescriptor] = []) -> Observable<(AnyRealmCollection<T>, RealmChangeset?)> {
        return Observable.deferred {
            let realm = self.realm
            let objects = realm.objects(model)
                .filter(predicate)
            //.sorted(by: sortDescriptors.map(SortDescriptor.init))
            return Observable.changeset(from: objects)
        }
    }
    
    func fetchResults<T: Object>(_ model: T.Type,
                          with predicate: NSPredicate,
                          sortDescriptors: [NSSortDescriptor] = []) -> Observable<[T]> {
        return Observable.deferred {
            let realm = self.realm
            let objects = realm.objects(model)
                .filter(predicate)
                .toArray()
            //.sorted(by: sortDescriptors.map(SortDescriptor.init))
            return Observable.of(objects)
        }
    }
    
    func fetchAllResults<T: Object>(_ model: T.Type) -> Observable<[T]> {
        return Observable.deferred {
            let realm = self.realm
            let objects = realm.objects(model)
                .toArray()
            //.sorted(by: sortDescriptors.map(SortDescriptor.init))
            return Observable.of(objects)
        }
    }
    
    func fetchObjects<T: Object>(_ model: T.Type, with predicate: NSPredicate) -> [T] {
        let realm = self.realm
        let objects = realm.objects(model)
            .filter(predicate)
            .toArray()
        //.sorted(by: sortDescriptors.map(SortDescriptor.init))
        return objects
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
    
    func updateWrite(block: @escaping () -> Void) {
        try! self.realm.write {
            block()
        }
    }
    
    func fetchPromise<T: Object>(_ model: T.Type, with predicate: NSPredicate) -> Promise<[T]> {
        return Promise { fullfill, _ in
            let realm = self.realm
            let objects = realm.objects(model)
                .filter(predicate)
                .toArray()
            fullfill(objects)
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

    func save<R: Object>(_ object: R, update: Bool = true) -> Observable<R> {
        return Observable.create { observer in
            do {
                try self.base.write {
                    self.base.add(object, update: update)
                }
                observer.onNext(object)
                observer.onCompleted()
            } catch {
                observer.onError(error)
            }
            return Disposables.create()
        }
    }
    
    func save<R: Object>(_ objects: [R], update: Bool = true) -> Observable<Void> {
        return Observable.create { observer in
            do {
                try self.base.write {
                    self.base.add(objects, update: update)
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


