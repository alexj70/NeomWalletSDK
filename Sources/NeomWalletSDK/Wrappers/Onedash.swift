import Foundation

@propertyWrapper public struct Onedash {
    public var wrappedValue: String {
        didSet { wrappedValue = wrappedValue.replacingOccurrences(of: "//", with: "/") }
    }

    public init(wrappedValue: String) {
        self.wrappedValue = wrappedValue.replacingOccurrences(of: "//", with: "/")
    }
}
