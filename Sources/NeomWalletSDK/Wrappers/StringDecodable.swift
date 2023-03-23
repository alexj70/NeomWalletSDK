import Foundation

@propertyWrapper
public struct StringDecodable<Wrapped: LosslessStringConvertible>: Decodable {
    public let wrappedValue: Wrapped

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = (try? container.decode(String.self)) ?? "0"
        if let value = Wrapped(string) {
            wrappedValue = value
        } else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Value \(string) is not convertible to \(Wrapped.self)"
            )
        }
    }
    
}

extension StringDecodable: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode("\(wrappedValue)")
    }
}
