//
//  WebLinkThumbnailService.swift
//  Abe
//
//  Created by Robert Rozenvasser on 1/16/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftLinkPreview
import RxSwift

final class WebLinkThumbnail: Object {
    @objc dynamic var id: String = NSUUID().uuidString
    @objc dynamic var url: String = ""
    @objc dynamic var finalUrl: String = ""
    @objc dynamic var canonicalUrl: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var mainImageUrl: String = ""
    @objc dynamic var icon: String = ""
    let secondaryImageUrls = List<String>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    convenience init(dictionary:  [SwiftLinkResponseKey: Any]) {
        self.init()
//        guard let url = dictionary[.url] as? String,
//              let canonicalUrl = dictionary[.canonicalUrl] as? String,
//              let title = dictionary[.title] as? String,
//              let imageUrl = dictionary[.image] as? String else { return nil }
        self.url = dictionary[.url] as? String ?? ""
        self.canonicalUrl = dictionary[.canonicalUrl] as? String ?? ""
        self.title = dictionary[.title] as? String ?? ""
        self.mainImageUrl = dictionary[.image] as? String ?? ""
    }
    
}

struct WebLinkThumbnailService {
   
    let linkPreview = SwiftLinkPreview()
    
    func fetchThumbnailFor(url: String) -> Observable<WebLinkThumbnail?> {
        return Observable.create { (observer) -> Disposable in
            self.linkPreview
                .preview(url,
                         onSuccess: { (response) in
                           observer.onNext(WebLinkThumbnail(dictionary: response) ?? nil)
                           observer.onCompleted()
                         }, onError: { (error) in
                           observer.onError(error)
                         })
            return Disposables.create()
        }
    }
    
}
