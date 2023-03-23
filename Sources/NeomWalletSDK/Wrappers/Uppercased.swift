import Foundation

@propertyWrapper public struct Uppercased {
    public var wrappedValue: String {
        didSet { wrappedValue = wrappedValue.uppercased() }
    }

    public init(wrappedValue: String) {
        self.wrappedValue = wrappedValue.uppercased()
    }
}
