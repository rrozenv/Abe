
import Foundation
import RxSwift
import RealmSwift

//protocol RealmRepresentable {
//    func create<T: Object>(_ model: T.Type, value: [String: Any], update: Bool) -> Observable<Void>
//    func save(object: Object) -> Observable<Void>
//    func fetch<T: Object>(_ model: T.Type) -> Observable<(AnyRealmCollection<T>, RealmChangeset?)>
//    func fetch<T: Object>(_ model: T.Type, primaryKey: String) -> Observable<T?>
//    func queryAll<T: Object>(_ model: T.Type) -> Observable<Results<T>>
//    func query<T: Object>(_ model: T.Type, with predicate: NSPredicate, sortDescriptors: [NSSortDescriptor]) -> Observable<Results<T>>
//    func update(block: @escaping () -> Void) -> Observable<Void>
//    func delete<T: Object>(_ object: T) -> Observable<Void>
//    func save<T: Object>(object: T, update: Bool) -> AnyObserver<T>
//}

