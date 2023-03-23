import Foundation

public protocol SetCurrencyDataProvider {
    func setCurrency(currency: String) async throws -> Bool
}


struct SetCurrencyEndpoint: EndpointProtocol {
    typealias Response = SetCurrencyResult
    typealias InputType = SetCurrencyInput
    var input: InputType
    
    var path: String { "/api/v1/user/currency" }
    var httpmethod: HttpUrlMethod { .POST }
    var bodyData: Data? { try? JSONEncoder().encode(input) }
}


extension NeomWalletSDK: SetCurrencyDataProvider {
    public func setCurrency(currency: String) async throws -> Bool {
        let endpoint = SetCurrencyEndpoint(input: SetCurrencyInput(currency: currency.uppercased()))
        let value = try await service.fetch(endpoint)
        return value.isSuccess
    }
}
