import Foundation

public protocol ChangePasswordDataProvider {
    func updatePassword(new: String) async throws
}


struct ChangePasswordEndpoint: EndpointProtocol {
    typealias Response = ChangePasswordResult
    typealias InputType = ChangePasswordInput
    var input: InputType
    
    var path: String { "/api/v1/user/password" }
    var httpmethod: HttpUrlMethod { .POST }
    var bodyData: Data? { try? JSONEncoder().encode(input) }
}


extension NeomWalletSDK: ChangePasswordDataProvider {
    public func updatePassword(new: String) async throws {
        let endpoint = ChangePasswordEndpoint(input: ChangePasswordInput(newPassword: new))
        let value = try await service.fetch(endpoint)
        guard value.isSuccess else { return }
        let user = NeomUser.me
        user?.password = new
        NeomUser.me = user
    }
}
