import Foundation

public protocol GetProfileDataProvider {
    func profile() async throws -> GetProfileResult
}


struct GetProfileEndpoint: EndpointProtocol {
    typealias Response = GetProfileResult
    typealias InputType = Void
    var input: InputType = Void()
    
    var path: String { "/api/v1/user/profile" }
    var httpmethod: HttpUrlMethod { .GET }
}


extension NeomWalletSDK: GetProfileDataProvider {
    public func profile() async throws -> GetProfileResult {
        let endpoint = GetProfileEndpoint()
        var value = try await service.fetch(endpoint)
        value.token = NeomWalletSDK.token!
        return value
    }
}
