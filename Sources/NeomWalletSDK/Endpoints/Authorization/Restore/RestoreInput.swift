import Foundation

public struct RestoreInput: Encodable {
    let signature: String
    let ethPublicKey: String?
    let currentPassword: String?
    let newPassword: String
    
    public init(nonce: Int, ethPublicKey: String?, currentPassword: String?, newPassword: String) {
        let str =  "“I am signing my one-time nonce: \(nonce)"
        // RSA test.
//        do {
//
//            let keyPair = try SecKey.createRandomKey(
//                type: .rsa,
//                bits: 2048)
//            let publicKey = try keyPair.publicKey()
//            let plain = "Chuck Norris can set ants on fire with a magnifying glass. At night.".data(using: .utf8)!
//            let ciphertext = try publicKey.encrypt(
//                algorithm: .rsaEncryptionOAEPSHA1AESGCM,
//                plaintext: plain)
//            let plainAgain = try keyPair.decrypt(
//                algorithm: .rsaEncryptionOAEPSHA1AESGCM,
//                ciphertext: ciphertext)
//            let string = String(data: plainAgain, encoding: .utf8)! // Don't force-unwrap in real code.
//            print("RSA decrypted: " + string)
//        } catch {
//            print("Error: \(error)")
//        }
//
        
        self.signature = str
        self.ethPublicKey = ethPublicKey
        self.currentPassword = currentPassword
        self.newPassword = newPassword
    }
}
