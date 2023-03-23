import Foundation

public protocol SendTransactionDataProvider {
    @discardableResult
    func send(transaction model: SendTransactionInput) async throws -> Endpoint.Transaction
}

struct SendTransactionEndpoint: EndpointProtocol {
    typealias Response = Endpoint.Transaction
    typealias InputType = SendTransactionInput
    var input: InputType
    var isDebugEnabled: Bool = true
    
    var path: String { "/api/v1/transaction" }
    var httpmethod: HttpUrlMethod { .POST }
    var bodyData: Data? { try? JSONEncoder().encode(input) }
}

extension NeomWalletSDK: SendTransactionDataProvider {
    @discardableResult
    public func send(transaction model: SendTransactionInput) async throws -> Endpoint.Transaction {
        let endpoint = SendTransactionEndpoint(input: model)
        return try await service.fetch(endpoint)
    }
}
