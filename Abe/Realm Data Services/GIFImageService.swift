//
//  GIFImageService.swift
//  Abe
//
//  Created by Robert Rozenvasser on 1/17/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import Moya
import RxSwift

struct ImageService<T: TargetType> {
    let provider = MoyaProvider<T>()
}

extension ImageService where T == GifAPI {
    
    func fetchGIFS(query: String, offset: Int) -> Observable<[ImageRepresentable]?> {
        return provider.rx
            .request(.search(query: query, offset: offset))
            .filter(statusCodes: 200...300).asObservable()
            .mapJSON()
            .map { GIF.allForQuery(json: $0) }
//            .mapOptional(to: GIFImageResource.self)
//            .map { $0?.data }
    }
    
}

extension ImageService where T == PixabayAPI {
    
    func fetchImages(query: String, page: Int) -> Observable<[ImageRepresentable]?> {
        return provider.rx
            .request(.search(query: query, page: page))
            .filter(statusCodes: 200...300).asObservable()
            .mapOptional(to: PixaImageResource.self)
            .map { $0?.hits }
    }
    
}
