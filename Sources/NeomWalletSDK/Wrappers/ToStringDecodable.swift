@propertyWrapper
public struct ToStringDecodable: Decodable {
    public let wrappedValue: String

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        do {
            let intValue = try container.decode(Int.self)
            wrappedValue = "\(intValue)".trimmingCharacters(in: .whitespacesAndNewlines)
            return
        }
        catch {}
        
        wrappedValue = try container.decode(String.self)
    }
    
}

extension ToStringDecodable: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode("\(wrappedValue)")
    }
}
