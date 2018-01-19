
import Foundation
import RealmSwift
import SwiftLinkPreview
import RxSwift

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

//struct WebLinkThumbnailViewModel {
//    let url: String
//    let canonicalUrl: String
//    let title: String
//    let imageUrl: String
//}
//
//extension WebLinkThumbnailViewModel {
//    init(thumbnail: WebLinkThumbnail) {
//        self.url = thumbnail.url
//        self.canonicalUrl = thumbnail.canonicalUrl
//        self.title = thumbnail.title
//        self.imageUrl = thumbnail.mainImageUrl
//    }
//}

