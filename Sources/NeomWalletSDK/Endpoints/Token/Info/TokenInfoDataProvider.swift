

public protocol TokenInfoDataProvider {
    func getTokenInfo(address: String) async throws -> Endpoint.TokenInfo
}


struct TokenInfoEndpoint: EndpointProtocol {
    typealias Response = TokenInfoResult
    typealias InputType = TokenInfoInput
    var input: InputType
    
    var path: String { "/api/v1/contract/" }
    var httpmethod: HttpUrlMethod { .GET }
    var parameters: [String : String]? {
        [
            "contractAddress": input.contractAddress
        ]
    }
}


extension NeomWalletSDK: TokenInfoDataProvider {
    public func getTokenInfo(address: String) async throws -> Endpoint.TokenInfo {
        let endpoint = TokenInfoEndpoint(input: TokenInfoInput(contractAddress: address))
        let result = try await service.fetch(endpoint)
        return result.value
    }
}
