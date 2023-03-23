import Foundation


@propertyWrapper
public struct DateDecodable: Decodable {
    public let wrappedValue: Date

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(identifier: "UTC")!
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        
        if let value = formatter.date(from: string) {
            wrappedValue = value
        } else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Value \(string) is not convertible to \(Date.self)"
            )
        }
        
    }
}
