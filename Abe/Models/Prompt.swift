
import Foundation
import RealmSwift
import RxSwift

class Prompt: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var body: String = ""
    @objc dynamic var imageURL: String = ""
    @objc dynamic var user: User?
    @objc dynamic var createdAt = Date()
    let replies = List<PromptReply>()
    
    override static func primaryKey() -> String? {
        return "id"
    }

    convenience init(id: String,
                     title: String,
                     body: String,
                     user: User) {
        self.init()
        self.id = id
        self.title = title
        self.body = body
        self.user = user
        //self.imageURL = imageURL
    }
    
    var value: [String: Any] {
        return ["id": UUID().uuidString,
                "title": title,
                "body": body]
    }
    
}

protocol EntityConvertibleType {
    associatedtype EntityType
    func asEntity() -> EntityType
}

final class RMPost: Object {
    @objc dynamic var uid: String = ""
    @objc dynamic var userId: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var body: String = ""
    @objc dynamic var createdAt: String = ""
    
    override class func primaryKey() -> String? {
        return "uid"
    }
}

extension Object {
    static func build<O: Object>(_ builder: (O) -> () ) -> O {
        let object = O()
        builder(object)
        return object
    }
}

protocol RealmRepresent {
    associatedtype RealmType: EntityConvertibleType
    
    var uid: String {get}
    
    func asRealm() -> RealmType
}


extension RMPost: EntityConvertibleType {
    func asEntity() -> Post {
        return Post(body: body,
                    title: title,
                    uid: uid,
                    userId: userId,
                    createdAt: createdAt)
    }
}

extension Post: RealmRepresent {
    func asRealm() -> RMPost {
        return RMPost.build { object in
            object.uid = uid
            object.userId = userId
            object.title = title
            object.body = body
            object.createdAt = createdAt
        }
    }
}

public struct Post {
    public let body: String
    public let title: String
    public let uid: String
    public let userId: String
    public let createdAt: String
    
    public init(body: String,
                title: String,
                uid: String,
                userId: String,
                createdAt: String) {
        self.body = body
        self.title = title
        self.uid = uid
        self.userId = userId
        self.createdAt = createdAt
    }
    
    public init(body: String, title: String) {
        self.init(body: body, title: title, uid: NSUUID().uuidString, userId: "5", createdAt: String(round(Date().timeIntervalSince1970 * 1000)))
    }
}

extension Post: Equatable {
    public static func == (lhs: Post, rhs: Post) -> Bool {
        return lhs.uid == rhs.uid &&
            lhs.title == rhs.title &&
            lhs.body == rhs.body &&
            lhs.userId == rhs.userId &&
            lhs.createdAt == rhs.createdAt
    }
}

protocol AbstractRepository {
    associatedtype T
    func queryAll() -> Observable<[T]>
    func query(with predicate: NSPredicate,
               sortDescriptors: [NSSortDescriptor]) -> Observable<[T]>
    func save(entity: T) -> Observable<Void>
    func delete(entity: T) -> Observable<Void>
}

final class Repository<T: RealmRepresent>: AbstractRepository where T == T.RealmType.EntityType, T.RealmType: Object {
    
    private let configuration: Realm.Configuration
    
    private var realm: Realm {
        return try! Realm(configuration: self.configuration)
    }
    
    init(configuration: Realm.Configuration) {
        self.configuration = configuration
    }
    
    func queryAll() -> Observable<[T]> {
        return Observable.deferred {
            let realm = self.realm
            let objects = realm.objects(T.RealmType.self)
            
            return Observable.array(from: objects).mapToDomain()
            }
    }
    
    func query(with predicate: NSPredicate,
               sortDescriptors: [NSSortDescriptor] = []) -> Observable<[T]> {
        return Observable.deferred {
            let realm = self.realm
            let objects = realm.objects(T.RealmType.self)
                .filter(predicate)
                //.sorted(by: sortDescriptors.map(SortDescriptor.init))
            
            return Observable.array(from: objects)
                .mapToDomain()
            }
    }
    
    func save(entity: T) -> Observable<Void> {
        return Observable.deferred {
            return self.realm.rx
            }
    }
    
    func delete(entity: T) -> Observable<Void> {
        return Observable.deferred {
            return self.realm.rx.delete(entity: entity)
            }
    }
    
}


extension Observable where Element: Sequence, Element.Iterator.Element: EntityConvertibleType {
    typealias DomainType = Element.Iterator.Element.EntityType
    
    func mapToDomain() -> Observable<[DomainType]> {
        return map { sequence -> [DomainType] in
            return sequence.mapToDomain()
        }
    }
}

extension Sequence where Iterator.Element: EntityConvertibleType {
    typealias Element = Iterator.Element
    func mapToDomain() -> [Element.EntityType] {
        return map {
            return $0.asEntity()
        }
    }
}






