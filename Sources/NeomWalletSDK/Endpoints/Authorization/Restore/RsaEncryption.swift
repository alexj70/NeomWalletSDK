import Security
import Foundation

// See: https://developer.apple.com/documentation/security/certificate_key_and_trust_services/keys
public extension SecKey {
    
    enum KeyType {
        case rsa
        case ellipticCurve
        var secAttrKeyTypeValue: CFString {
            switch self {
            case .rsa:
                return kSecAttrKeyTypeRSA
            case .ellipticCurve:
                return kSecAttrKeyTypeECSECPrimeRandom
            }
        }
    }
    
    /// Creates a random key.
    /// Elliptic curve bits options are: 192, 256, 384, or 521.
    static func createRandomKey(type: KeyType, bits: Int) throws -> SecKey {
        var error: Unmanaged<CFError>?
        let keyO = SecKeyCreateRandomKey([
            kSecAttrKeyType: type.secAttrKeyTypeValue,
            kSecAttrKeySizeInBits: NSNumber(integerLiteral: bits),
        ] as CFDictionary, &error)
        // See here for apple's sample code for memory-managing returned errors
        // from the Security framework:
        
        // https://developer.apple.com/documentation/security/certificate_key_and_trust_services/keys/storing_keys_as_data
        if let error = error?.takeRetainedValue() { throw error }
        guard let key = keyO else { throw MyErrors.nilKey }
        return key
    }
    
    /// Gets the public key from a key pair.
    func publicKey() throws -> SecKey {
        let publicKeyO = SecKeyCopyPublicKey(self)
        guard let publicKey = publicKeyO else { throw MyErrors.nilPublicKey }
        return publicKey
    }
    
    /// Exports a key.
    /// RSA keys are returned in PKCS #1 / DER / ASN.1 format.
    /// EC keys are returned in ANSI X9.63 format.
    func externalRepresentation() throws -> Data {
        var error: Unmanaged<CFError>?
        let dataO = SecKeyCopyExternalRepresentation(self, &error)
        if let error = error?.takeRetainedValue() { throw error }
        guard let data = dataO else { throw MyErrors.nilExternalRepresentation }
        return data as Data
    }
    
    // Self must be the public key returned by publicKey().
    // Algorithm should be SecKeyAlgorithm.rsaEncryption* or .eciesEncryption*
    func encrypt(algorithm: SecKeyAlgorithm, plaintext: Data) throws -> Data {
        var error: Unmanaged<CFError>?
        let ciphertextO = SecKeyCreateEncryptedData(self, algorithm,
            plaintext as CFData, &error)
        if let error = error?.takeRetainedValue() { throw error }
        guard let ciphertext = ciphertextO else { throw MyErrors.nilCiphertext }
        return ciphertext as Data
    }
    
    // Self must be the private/public key pair returned by createRandomKey().
    // Algorithm should be SecKeyAlgorithm.rsaEncryption* or .eciesEncryption*
    func decrypt(algorithm: SecKeyAlgorithm, ciphertext: Data) throws -> Data {
        var error: Unmanaged<CFError>?
        let plaintextO = SecKeyCreateDecryptedData(self, algorithm,
            ciphertext as CFData, &error)
        if let error = error?.takeRetainedValue() { throw error }
        guard let plaintext = plaintextO else { throw MyErrors.nilPlaintext }
        return plaintext as Data
    }

    enum MyErrors: Error {
        case nilKey
        case nilPublicKey
        case nilExternalRepresentation
        case nilCiphertext
        case nilPlaintext
    }

}
