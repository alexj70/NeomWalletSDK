import Foundation

struct LoginInput: Encodable {
    let password: String
    let ethPublicKey: String?
    
    init( password: String) {
        self.password = password
        self.ethPublicKey = NeomUser.me.publicKey
    }
}
