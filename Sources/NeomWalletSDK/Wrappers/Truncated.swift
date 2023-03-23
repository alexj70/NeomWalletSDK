import Foundation

@propertyWrapper public struct Truncated<Value: RangeReplaceableCollection> {
    public var wrappedValue: Value {
        didSet { wrappedValue = Value(wrappedValue.prefix(maxLength)) }
    }
    public var maxLength: Int

    public init(wrappedValue: Value, maxLength: Int) {
        self.wrappedValue = Value(wrappedValue.prefix(maxLength))
        self.maxLength = maxLength
    }
}
