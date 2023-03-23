protocol NetworkProvider {
    func fetch<T>(_ endpoint: T) async throws -> T.Response where T : EndpointProtocol, T.Response : Decodable
}
