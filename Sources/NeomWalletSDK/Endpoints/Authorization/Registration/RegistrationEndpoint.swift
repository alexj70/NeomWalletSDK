import Foundation

public protocol RegistrationDataProvider {
    func register(user model: NeomUser) async throws
}


struct RegistrationEndpoint: EndpointProtocol {
    typealias Response = RegistrationResult
    typealias InputType = RegistrationInput
    var input: InputType
    
    
    var path: String { "/api/v1/auth/registration" }
    var isAuthorized: Bool { false }
    var httpmethod: HttpUrlMethod { .POST }
    
    var bodyData: Data? { try? JSONEncoder().encode(input) }
}



extension NeomWalletSDK: RegistrationDataProvider {
    public func register(user model: NeomUser) async throws {
        NeomWalletSDK.logout()
        let endpoint = RegistrationEndpoint(input: .init(with: model))
        let value = try await service.fetch(endpoint)
        NeomWalletSDK.token = value.token
        NeomUser.me = model
    }
}
