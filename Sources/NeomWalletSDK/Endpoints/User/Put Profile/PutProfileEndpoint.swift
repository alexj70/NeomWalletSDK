import Foundation

public protocol PutProfileDataProvider {
    func savePersonal(info: PersonalInfo) async throws
}


struct PutProfileEndpoint: EndpointProtocol {
    typealias Response = PutProfileResult
    typealias InputType = PutProfileInput
    var input: InputType
    
    var path: String { "/api/v1/user/profile" }
    var httpmethod: HttpUrlMethod { .PUT }
    var bodyData: Data? { try? JSONEncoder().encode(input) }
}


extension NeomWalletSDK: PutProfileDataProvider {
    public func savePersonal(info: PersonalInfo) async throws {
        let endpoint = PutProfileEndpoint(input: PutProfileInput(info: info))
        let result = try await service.fetch(endpoint)
        let user = NeomUser.me
        user?.fullName = result.fullName
        user?.email = result.email
        user?.phone = result.phoneNumber
        NeomUser.me = user
    }
}
