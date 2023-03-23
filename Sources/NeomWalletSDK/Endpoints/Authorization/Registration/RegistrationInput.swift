import Foundation

struct RegistrationInput: Encodable {
    struct Wallet: Encodable {
        let token: String
        let publicKey: WalletPublicKey?
    }
    
    let password: String
    let phoneNumber: String?
    let email: String?
    let fullName: String?
    let wallets: [Wallet]
    
    init(with user: NeomUser) {
        self.password = user.password
        self.phoneNumber = user.phone
        self.email = user.email
        self.fullName = user.fullName
        self.wallets = [
            Wallet(token: "ETH", publicKey: user.publicKey)
        ]
    }
}
