// https://www.advancedswift.com/secure-private-data-keychain-swift/

import Foundation
import Security

public protocol LoginDataProvider {
    func login(password model: String) async throws
}


struct LoginEndpoint: EndpointProtocol {
    typealias Response = LoginResult
    typealias InputType = LoginInput
    var input: InputType
    
    var path: String { "/api/v1/auth/appLogin" }
    var isAuthorized: Bool { false }
    var httpmethod: HttpUrlMethod { .POST }
    
    var bodyData: Data? { try? JSONEncoder().encode(input) }
}


extension NeomWalletSDK: LoginDataProvider {
    public func login(password model: String) async throws{
        let endpoint = LoginEndpoint(input: .init(password: model))
        let value = try await service.fetch(endpoint)
        let user = NeomUser.me
        user?.password = model
        user?.email = value.user.email
        user?.phone = value.user.phoneNumber
        user?.fullName = value.user.fullName
        NeomUser.me = user
        NeomWalletSDK.token = value.token
        
        guard let account = NeomUser.me.email else {
            return
        }
        
        guard let server = NeomWalletSDK.urlComponents.host else {
            return
        }
        
        let password = NeomUser.me.password.data(using: .utf8)!
//        try? KeychainInterface.deletePassword(service: server, account: account)
        
        do {
//            if let saved = try KeychainInterface.readPassword(service: server, account: account) {
//                if password != saved {
//                    try KeychainInterface.update(password: password, service: server, account: account)
//                }
//            } else {
                try KeychainInterface.save(password: password, service: server, account: account)
//            }
        }
        catch {
            debugPrint("👍 ", String(describing: type(of: self)),":", #function, " ", error)
        }
        
        
    }
}
