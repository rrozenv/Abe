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

struct WebLinkThumbnailViewModel {
    let url: String 
    let canonicalUrl: String
    let title: String
    let imageUrl: String
}

extension WebLinkThumbnailViewModel {
    init(thumbnail: WebLinkThumbnail) {
        self.url = thumbnail.url
        self.canonicalUrl = thumbnail.canonicalUrl
        self.title = thumbnail.title
        self.imageUrl = thumbnail.mainImageUrl
    }
}

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
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    convenience init?(dictionary: [SwiftLinkResponseKey: Any]) {
        self.init()
        print("url: \(String(describing: dictionary[.url] as? NSURL))")
        print("canonicalUrl: \(String(describing: dictionary[.canonicalUrl] as? NSURL))")
        print("title: \(String(describing: dictionary[.title] as? String))")
        print("imageUrl: \(String(describing: dictionary[.image] as? String))")
        guard let url = (dictionary[.url] as? NSURL)?.absoluteString,
              let title = dictionary[.title] as? String,
              let imageUrl = dictionary[.image] as? String else { return nil }
        self.url = url
        self.canonicalUrl = (dictionary[.canonicalUrl] as? NSURL)?.absoluteString ?? ""
        self.title = title
        self.mainImageUrl = imageUrl
    }
    
}

enum WebLinkThumbnailServiceError: Error {
    case missingInfo
}

struct WebLinkThumbnailService {
   
    let linkPreview = SwiftLinkPreview()
    
    func fetchThumbnailFor(url: String) -> Observable<WebLinkThumbnail> {
        return Observable.create { (observer) -> Disposable in
            self.linkPreview.preview(url,
                         onSuccess: { (response) in
                            if let thumbnail = WebLinkThumbnail(dictionary: response) {
                                observer.onNext(thumbnail)
                            } else {
                                observer.onError(WebLinkThumbnailServiceError.missingInfo)
                            }
                            observer.onCompleted()
                         }, onError: { (error) in
                            observer.onError(error)
                         })
            return Disposables.create()
        }
    }
    
}
