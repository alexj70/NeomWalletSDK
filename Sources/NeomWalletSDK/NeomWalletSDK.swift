import Foundation
import KeychainSwift

public final class NeomWalletSDK {
    internal var service: NetworkService
    public static var isDebugEnabled: Bool = true
    public static var enviroment: Enviroment = .default
    public static var onUserNotFound: (() -> Void)?
    
    public static var isAuthorized: Bool {
        NeomWalletSDK.token != nil
    }
    
    internal static var token: String? {
        get {
            guard let data = KeychainSwift().getData(#function) else {
                return nil
            }
            return try? JSONDecoder().decode(String.self, from: data)
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

    static var urlComponents: URLComponents {
        var components = URLComponents()
        components.scheme = "https"
        
        switch NeomWalletSDK.enviroment {
        case .staging:
            components.host = "api-dn.neom-dev.ml"
        case .production:
            components.host = "api-dn.neom-dev.ml"
        }

        
        return components
    }
    
    
    public init(session: URLSession = .shared) {
        service = NetworkService(session: session)
    }
    
    public static func logout() {
        NeomWalletSDK.token = nil
        NeomUser.me = nil
    }
    
}
