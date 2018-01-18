
import Foundation
import Moya

struct GIFImageResource: Codable {
    let data: [GIF]
}

struct GIF: ImageRepresentable, Codable {

    var id: String
    var webformatURL: String
    
    private enum CodingKeys: String, CodingKey {
        case id
        case webformatURL = "url"
    }
    
    init?(dictionary: JSONDictionary) {
        guard let id = dictionary["id"] as? String,
              let images = dictionary["images"] as? [String: Any],
              let original = images["downsized"] as? [String: Any],
              let url = original["url"] as? String else { return nil }
        self.id = id
        self.webformatURL = url
    }
}

extension GIF {
    
    static func allForQuery(json: Any) -> [GIF]? {
        guard let jsonDict = json as? JSONDictionary else { return nil }
        guard let dictionaries = jsonDict["data"] as? [JSONDictionary] else { return nil }
        return dictionaries.flatMap({ (dictionary) -> GIF? in
            return GIF(dictionary: dictionary)
        })
    }
    
    static func createFromCache(with data: Data) -> GIF? {
        guard let json = try? JSONSerialization.jsonObject(with: data, options: [.allowFragments]) else {
            return nil
        }
        guard let jsonDict = json as? JSONDictionary else { return nil }
        return GIF(dictionary: jsonDict)
    }
    
}

extension GIF {
    
    static func GIFResource(for query: String) -> Resource<[GIF]> {
        return Resource<[GIF]>(target: GifAPI.search(query: query)) { json -> [GIF]? in
            guard let jsonDict = json as? JSONDictionary else { return nil }
            guard let dictionaries = jsonDict["data"] as? [JSONDictionary] else { return nil }
            return dictionaries.flatMap({ (dictionary) -> GIF? in
                return GIF(dictionary: dictionary)
            })
        }
    }
    
}

struct Resource<A> {
    let target: TargetType
    let parse: (Data) -> A?
}

extension Resource {
    init(target: TargetType, parseJSON: @escaping (Any) -> A?) {
        self.target = target
        self.parse = { data -> A? in
            let json = try? JSONSerialization.jsonObject(with: data, options: [.allowFragments])
            return json.flatMap(parseJSON)
        }
    }
}


