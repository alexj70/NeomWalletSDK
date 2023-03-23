
public protocol FetchTokensDataProvider {
    func fetchTokenList() async throws -> [Endpoint.Token]
}


struct FetchTokensEndpoint: EndpointProtocol {
    typealias Response = [Endpoint.Token]
    typealias InputType = Void
    var input: InputType = Void()
    
    var path: String { "/api/v1/assets" }
    var httpmethod: HttpUrlMethod { .GET }
}


extension NeomWalletSDK: FetchTokensDataProvider {
    public func fetchTokenList() async throws -> [Endpoint.Token] {
        let endpoint = FetchTokensEndpoint()
        let value = try await service.fetch(endpoint)
        return value
    }
}
