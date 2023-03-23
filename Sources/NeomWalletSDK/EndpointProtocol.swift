import Foundation


enum HttpUrlMethod: String {
    case GET, POST, PATCH, PUT, DELETE
}

protocol EndpointProtocol {
    associatedtype Response
    associatedtype InputType
    
    var isAuthorized: Bool { get }
    var isDebugEnabled: Bool { get }
    var path: String { get }
    var httpmethod: HttpUrlMethod { get }
    var parameters: [String: String]? { get }
    var bodyData: Data? { get }
    var contentType: String? { get }
    var input: InputType { get set }
    
}

//private var __token: String = ""

extension EndpointProtocol {
    
    var method: HttpUrlMethod { return .GET }

    
    var isAuthorized: Bool { true }
    var bodyData: Data? { nil }
    var parameters: [String: String]? { nil }
    var contentType: String? { "application/json" }
    var isDebugEnabled: Bool { false }
    
    var request: URLRequest {
        var components = NeomWalletSDK.urlComponents
        let path = "/\(path)"
        components.path = path.replacingOccurrences(of: "//", with: "/")
        
        var queryItems: [URLQueryItem] = []
        for (key, value) in parameters ?? [:] {
            queryItems.append(URLQueryItem(name: key, value: value))
        }
        components.queryItems = queryItems
        var request = URLRequest(url: components.url!)
        request.httpMethod = httpmethod.rawValue
        request.httpBody = bodyData
        if let contentType = contentType {
            request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        }
        
        if let token = NeomWalletSDK.token, isAuthorized {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            debugPrint("UNAUTHORIZED")
        }
        
        request.timeoutInterval = 120
        return request
    }
    
}
