import Foundation

@propertyWrapper public struct Capitalized {
    public var wrappedValue: String {
        didSet { wrappedValue = wrappedValue.capitalized }
    }

    public init(wrappedValue: String) {
        self.wrappedValue = wrappedValue.capitalized
    }
}

