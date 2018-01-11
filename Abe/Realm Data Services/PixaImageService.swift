
import Foundation
import Moya
import RxSwift

struct PixaImage: Codable {
    let id: Int
    let webformatURL: String
}

struct PixaImageResource: Codable {
    let totalHits: Int
    let hits: [PixaImage]
}

struct PixaImageService {
    
    let provider = MoyaProvider<PixabayAPI>()
    
    func fetchImages(query: String, page: Int) -> Observable<[PixaImage]> {
        return provider.rx
            .request(.search(query: query, page: page))
            .debug()
            .filter(statusCodes: 200...300)
            .asObservable()
            .map(to: PixaImageResource.self)
            .map { $0.hits }
    }
    
}


public extension ObservableType where E == Moya.Response {
    
    public func map<T>(to type: T.Type, using decoder: JSONDecoder = JSONDecoder()) -> Observable<T> where T: Swift.Decodable {
        return map {
            try $0.map(type, using: decoder)
        }
    }
    
}

public extension Moya.Response {
    
    public func map<T>(to type: T.Type, using decoder: JSONDecoder = JSONDecoder()) throws -> T where T: Swift.Decodable {
        let decoder = decoder
        return try decoder.decode(type, from: data)
    }
    
}


