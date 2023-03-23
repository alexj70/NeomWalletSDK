import Security
import Foundation

public protocol LogoutDataProvider {
    func logout() async throws
}


struct LogoutEndpoint: EndpointProtocol {
    typealias Response = LogoutResult
//    typealias InputType = LogoutInput
    typealias InputType = Void
    var input: InputType = Void()
    
    var path: String { "/api/v1/auth/logout" }
    var httpmethod: HttpUrlMethod { .POST }
}


extension NeomWalletSDK: LogoutDataProvider {
    public func logout() async throws {
        let endpoint = LogoutEndpoint()
        let result = try await service.fetch(endpoint)
        if !result.isSuccess {
            throw NSError.failedResult
        }
    }
}
