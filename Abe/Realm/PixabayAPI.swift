
import Foundation
import Moya

typealias JSONDictionary = [String: Any]

protocol ImageRepresentable {
    var id: String { get }
    var urlString: String { get }
    var totalHitCount: Int { get }
}

struct PixaImage: ImageRepresentable {
    var id: String
    var urlString: String
    var totalHitCount: Int
    
    init?(dictionary: JSONDictionary) {
        guard let id = dictionary["id"] as? String,
            let urlString = dictionary["url"] as? String else { return nil }
        self.id = id
        self.urlString = urlString
        self.totalHitCount = 0
    }
}

struct Secrets {
    static let API_Key = "vEuTgt5WkT4zs4hbPe6CXjEEiMIdTZXm"
    static let pixabayAPI_Key = "7195286-a0abf18d1b041a5e368666cee"
}

enum PixabayAPI {
    case search(query: String, page: Int)
}

extension PixabayAPI: TargetType {
    
    // 3:
    var baseURL: URL {
        switch self {
        case .search(query: _):
            return URL(string: "https://pixabay.com/api/")!
        }
    }
    
    // 4:
    var path: String {
        switch self {
        case .search(query: _, page: _):
            return ""
        }
    }
    
    // 5:
    var method: Moya.Method {
        switch self {
        default: return .get
        }
    }
    
    // 6:
    var parameters: [String: Any]? {
        var parameters = [String: Any]()
        parameters["key"] = Secrets.pixabayAPI_Key
        switch self {
        case .search(query: let query, page: let page):
            parameters["q"] = "\(query)"
            parameters["page"] = "\(page)"
            return parameters
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
    
    // 7:
    var parameterEncoding: ParameterEncoding {
        return URLEncoding.default
    }
    
    // 8:
    var sampleData: Data {
        return Data()
    }
    
    // 9:
    var task: Task {
        return .requestParameters(parameters: parameters!, encoding: parameterEncoding)
    }
}
