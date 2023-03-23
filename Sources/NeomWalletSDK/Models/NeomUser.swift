import Foundation
//import KeychainSwift
import KeychainSwift

public final class NeomUser: Codable, PersonalInfo {
    public var password: String = ""
    public var phone: String?
    public var countryCode: String?
    public var fullName: String?
    public var email: String?
    public var seedPhrase: SeedPhrase = .empty
    public var publicKey: WalletPublicKey?
    public var biometricEnabled: Bool = false
    public var points: Int = 0
    
    public init() {
        
    }
    
    public func copy() -> NeomUser {
        let user = NeomUser()
        user.password = password
        user.phone = phone
        user.fullName = fullName
        user.email = email
        user.seedPhrase = seedPhrase
        user.publicKey = publicKey
        user.biometricEnabled = biometricEnabled
        return user
    }
}

public extension NeomUser {
    static var canBeAuthorized: Bool {
        guard NeomUser.me != nil else {
            return false
        }
        
        guard NeomUser.me.seedPhrase != .empty else {
            return false
        }
        
        guard NeomWalletSDK.isAuthorized else {
            return false
        }
        
        return true
        
//        NeomUser.me != nil && NeomUser.me.seedPhrase != .empty && NeomUser.me.profileInfo?.isEmpty == false && NeomUser.me.token != nil
    }
    
    static var me: NeomUser! {
        get {
            guard let data = KeychainSwift().getData(#function) else {
                return nil
            }
            return try? JSONDecoder().decode(NeomUser.self, from: data)
        }
        set {
            let keychain = KeychainSwift()
            guard let newValue else {
                keychain.delete(#function)
                return
            }
            let data: Data
            do {
                data = try JSONEncoder().encode(newValue)
            }
            catch {
                assertionFailure(error.localizedDescription)
                return
            }
            
            keychain.set(data, forKey: #function)
        }
    }
}
