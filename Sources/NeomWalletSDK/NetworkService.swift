import Foundation
import Combine



struct ErrorResponse: Decodable {
    let error: APIError
}

struct APIError: Decodable {
    let code: Int
    let message: String
    
    var userInfo: [String: Any] { [NSLocalizedDescriptionKey : message] }
    
}



final class NetworkService: NetworkProvider {
    let session: URLSession
    var tokens: [AnyCancellable?]? = []
    
    public convenience init() {
        self.init(session: .shared)
    }
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    @discardableResult
    func fetch<T>(_ endpoint: T) async throws -> T.Response where T : EndpointProtocol, T.Response : Decodable {
        
        let request = endpoint.request
        
        if NeomWalletSDK.isDebugEnabled || endpoint.isDebugEnabled {
            if let data = endpoint.bodyData, let json = try? JSONSerialization.jsonObject(with: data) {
                debugPrint("⚠️ POST ", json)
            }
            debugPrint("🚀 ", String(describing: type(of: self)),":", #function, " ", request.url ?? "No URL")
            if endpoint.isAuthorized {
                debugPrint("Bearer \(NeomWalletSDK.token ?? "Not found")")
            }
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let cancellable = session
                .dataTaskPublisher(for: request)
                .receive(on: DispatchQueue.main)
                .tryMap() { element -> Data in
                    guard let httpResponse = element.response as? HTTPURLResponse else {
                        throw URLError(.badServerResponse)
                    }
                    
                    guard httpResponse.statusCode == 200 else {
                        let code = httpResponse.statusCode
                        switch code {
                        case 401 where endpoint.isAuthorized:
                            NeomWalletSDK.logout()
                            NeomWalletSDK.onUserNotFound?()
                            fallthrough
                        default:
                            let json = try? JSONSerialization.jsonObject(with: element.data, options: [])
                            let message = (json as? [String: Any])?["message"] as? String
                            debugPrint("👍 ", String(describing: type(of: self)),":", #function, " code ", code)
                            debugPrint("⚠️ ", String(describing: type(of: self)),":", #function, " ", json ?? "NO JSON" )
                            
                            let msg = message ?? (HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode) as Error).localizedDescription
                            let userInfo = [
                                NSLocalizedDescriptionKey: NSLocalizedString(msg, comment: "")
                            ]
                            throw NSError(domain: "", code: code, userInfo: userInfo)
                        }
                        
                    }
                    
                    if NeomWalletSDK.isDebugEnabled || endpoint.isDebugEnabled  {
                        let json = try? JSONSerialization.jsonObject(with: element.data, options: [])
                        debugPrint("⚠️ ", String(describing: type(of: self)),":", #function, " ", json ?? "NO JSON" )
                    }
                    
                    
                    let decoder = JSONDecoder()
                    if let error = try? decoder.decode(ErrorResponse.self, from: element.data).error {
                        throw URLError(URLError.Code(rawValue: error.code), userInfo: error.userInfo)
                    }
                    
                    return element.data
                }
                .decode(type: T.Response.self, decoder: JSONDecoder())
                .sink(
                    receiveCompletion: { completion in
                        switch completion {
                        case .failure(let error):
                            debugPrint("🚫 ", String(describing: type(of: self)),":", #function, " ", error)
                            continuation.resume(with: .failure(error))
                        case .finished:
                            break
                        }
                        
                    },
                    receiveValue: { value in
                        continuation.resume(with: .success(value))
                    }
                )
            tokens?.append(cancellable)
            
        }
    }
}
