import Foundation

public protocol RestoreDataProvider {
    func restore(for user: NeomUser, newPassword: String,  nonce: Int) async throws
}


struct RestoreEndpoint: EndpointProtocol {
    typealias Response = RestoreResult
    typealias InputType = RestoreInput
    var input: InputType
    
    
    var path: String { "/api/v1/auth/restorePassword" }
    var isAuthorized: Bool { false }
    var httpmethod: HttpUrlMethod { .POST }
    
    var bodyData: Data? { try? JSONEncoder().encode(input) }
}



extension NeomWalletSDK: RestoreDataProvider {
    public func restore(for user: NeomUser, newPassword: String,  nonce: Int) async throws {
        let model = RestoreInput(
            nonce: nonce,
            ethPublicKey: user.publicKey,
            currentPassword: user.password,
            newPassword: newPassword
        )
        let endpoint = RestoreEndpoint(input: model)
        let result = try await service.fetch(endpoint)
        if !result.isSuccess {
            throw NSError.failedResult
        }
        user.password = newPassword
        NeomUser.me = user
    }
}
