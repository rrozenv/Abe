
import Foundation
import RxSwift
import RealmSwift

protocol RealmRepresentable {
    func create<T: Object>(_ model: T.Type, value: [String: Any]) -> Observable<Void>
    func save(object: Object) -> Observable<Void>
    func queryAll<T: Object>(_ model: T.Type) -> Observable<Results<T>>
    func query<T: Object>(_ model: T.Type, with predicate: NSPredicate, sortDescriptors: [NSSortDescriptor]) -> Observable<Results<T>>
    func update(block: @escaping () -> Void) -> Observable<Void>
    func delete(object: Object) -> Observable<Void>
    func deleteAll() -> Observable<Void>
}
