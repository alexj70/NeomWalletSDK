import Foundation

@propertyWrapper public struct Lowercased {
    public var wrappedValue: String {
        didSet {
            wrappedValue = wrappedValue.lowercased()
        }
    }

    public init(wrappedValue: String) {
        self.wrappedValue = wrappedValue.lowercased()
    }
}
