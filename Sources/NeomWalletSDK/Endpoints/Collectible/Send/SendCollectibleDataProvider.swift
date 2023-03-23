import Foundation

public protocol SendCollectibleDataProvider {
    func sendNFT(tokenId: Int64, toWallet: String)  async throws
}


struct SendCollectibleEndpoint: EndpointProtocol {
    typealias Response = SendCollectibleResult
    typealias InputType = SendCollectibleInput
    var input: InputType
    
    
    var path: String { "/api/v1/nft/send"}
    var isAuthorized: Bool { true }
    var httpmethod: HttpUrlMethod { .POST }
    var bodyData: Data? { try? JSONEncoder().encode(input) }
    
}

extension NeomWalletSDK: SendCollectibleDataProvider {
    public func sendNFT(tokenId: Int64, toWallet: String)  async throws {
        let input = SendCollectibleInput(tokenId: tokenId, receiverAddress: toWallet)
        let endpoint = SendCollectibleEndpoint(input: input)
        let result = try await service.fetch(endpoint)
        if !result.isSuccess {
            throw NSError.failedResult
        }
        
    }
}
