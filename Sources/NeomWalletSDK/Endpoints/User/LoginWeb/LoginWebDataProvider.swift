import Foundation

public protocol LoginWebDataProvider {
    func loginWeb(publicKey value: String) async throws
}


struct LoginWebEndpoint: EndpointProtocol {
    typealias Response = LoginWebResult
    typealias InputType = LoginWebInput
    var input: InputType
    var isAuthorized: Bool = false
    
    var path: String { "/api/v1/auth/LoginWeb" }
    var httpmethod: HttpUrlMethod { .POST }
    var bodyData: Data? { try? JSONEncoder().encode(input) }
}


extension NeomWalletSDK: LoginWebDataProvider {
    public  func loginWeb(publicKey value: String) async throws {
        let input = LoginWebInput(publicKey: value)
        let endpoint = LoginWebEndpoint(input: input)
        let result = try await service.fetch(endpoint)
        if !result.isSuccess {
            throw NSError.failedResult
        }
    }
}
