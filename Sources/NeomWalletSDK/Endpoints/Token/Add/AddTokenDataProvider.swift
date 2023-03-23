import Foundation

public protocol AddTokenDataProvider {
    func addToken(input model: AddTokenInput) async throws
}


struct AddTokenEndpoint: EndpointProtocol {
    typealias Response = AddTokenResult
    typealias InputType = AddTokenInput
    var input: InputType
    
    var path: String { "/api/v1/contract/fromAddress" }
    var httpmethod: HttpUrlMethod { .POST }
    var bodyData: Data? { try? JSONEncoder().encode(input) }
}


extension NeomWalletSDK: AddTokenDataProvider {
    public func addToken(input model: AddTokenInput) async throws {
        let endpoint = AddTokenEndpoint(input: model)
        let result = try await service.fetch(endpoint)
        if !result.isSuccess {
            throw NSError.failedResult
        }
    }
}
