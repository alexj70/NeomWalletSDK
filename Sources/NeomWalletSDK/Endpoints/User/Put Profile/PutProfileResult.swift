public struct PutProfileResult: Decodable {
    public let phoneNumber: String
    public let email: String
    public let fullName: String
    public var token: String = ""
    
    enum CodingKeys: String, CodingKey {
        case phoneNumber
        case email
        case fullName
    }
    
}

