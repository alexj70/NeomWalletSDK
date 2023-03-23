import Foundation
public protocol AddCollectibleDataProvider {
    func addCollectible(tokenId: String) async throws -> Endpoint.Collectible
}

struct AddCollectibleEndpoint: EndpointProtocol {
    typealias Response = AddCollectibleResult
    typealias InputType = AddCollectibleInput
    var input: InputType
    
    var path: String { "/api/v1/nft/import" }
    var httpmethod: HttpUrlMethod { .POST }
    var bodyData: Data? { try? JSONEncoder().encode(input) }
}

extension NeomWalletSDK: AddCollectibleDataProvider {
    public func addCollectible(tokenId: String) async throws -> Endpoint.Collectible {
        let input = AddCollectibleInput(tokenId: tokenId)
        let endpoint = AddCollectibleEndpoint(input: input)
        return try await service.fetch(endpoint)
    }
}
