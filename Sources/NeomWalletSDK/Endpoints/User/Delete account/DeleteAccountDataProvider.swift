import Foundation

public protocol DeleteAccountDataProvider {
    func deleteAccount() async throws
}


struct DeleteAccountEndpoint: EndpointProtocol {
    typealias Response = DeleteAccountResult
    typealias InputType = DeleteAccountInput
    var input: InputType
    
    var path: String { "/api/v1/user" }
    var httpmethod: HttpUrlMethod { .DELETE }
    var bodyData: Data? { try? JSONEncoder().encode(input) }
}


extension NeomWalletSDK: DeleteAccountDataProvider {
    public func deleteAccount() async throws {
        let endpoint = DeleteAccountEndpoint(input: DeleteAccountInput())
        do {
            let value = try await service.fetch(endpoint)
            guard value.isSuccess else { return }
            NeomWalletSDK.logout()            
        }
        catch where error.code == 400 {
            NeomWalletSDK.logout()
        }
        catch {
            throw error
        }
        
    }
}
