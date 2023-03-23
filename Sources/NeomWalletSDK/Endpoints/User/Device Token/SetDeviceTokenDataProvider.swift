import Foundation

public protocol SetDeviceTokenDataProvider {
    func set(deviceToken value: String) async throws
}


struct SetDeviceTokenEndpoint: EndpointProtocol {
    typealias Response = SetDeviceTokenResult
    typealias InputType = SetDeviceTokenInput
    var input: InputType
    
    var path: String { "/api/v1/user/setDeviceToken" }
    var httpmethod: HttpUrlMethod { .POST }
    var bodyData: Data? { try? JSONEncoder().encode(input) }
}


extension NeomWalletSDK: SetDeviceTokenDataProvider {
    public func set(deviceToken value: String) async throws {
        let input = SetDeviceTokenInput(token: value)
        let endpoint = SetDeviceTokenEndpoint(input: input)
        let result = try await service.fetch(endpoint)
        if !result.isSuccess {
            throw NSError.failedResult
        }
    }
}
