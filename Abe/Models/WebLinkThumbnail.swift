
import Foundation
import RealmSwift
import SwiftLinkPreview

final class WebLinkThumbnail: Object {
    @objc dynamic var id: String = NSUUID().uuidString
    @objc dynamic var url: String = ""
    @objc dynamic var finalUrl: String = ""
    @objc dynamic var canonicalUrl: String = ""
    @objc dynamic var descrip: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var mainImageUrl: String = ""
    @objc dynamic var icon: String = ""
    let secondaryImageUrls = List<String>()
    
    override static func primaryKey() -> String? { return "id" }
    
    convenience init?(dictionary: [SwiftLinkResponseKey: Any]) {
        self.init()
//        print("url: \(String(describing: dictionary[.url] as? NSURL))")
//        print("canonicalUrl: \(String(describing: dictionary[.canonicalUrl] as? NSURL))")
//        print("title: \(String(describing: dictionary[.title] as? String))")
//        print("imageUrl: \(String(describing: dictionary[.image] as? String))")
        guard let url = (dictionary[.url] as? NSURL)?.absoluteString,
            let title = dictionary[.title] as? String,
            let imageUrl = dictionary[.image] as? String else { return nil }
        self.url = url
        self.canonicalUrl = (dictionary[.canonicalUrl] as? NSURL)?.absoluteString ?? ""
        self.title = title
        self.mainImageUrl = imageUrl
    }
    
}
