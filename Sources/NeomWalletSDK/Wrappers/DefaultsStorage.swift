import Foundation

@propertyWrapper
public struct DefaultsStorage<T: Codable> {
    private let key: String
    private let defaultValue: T

    public init(key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }

    public var wrappedValue: T {
        get {
            if T.self == Bool.self {
                if UserDefaults.standard.value(forKey: key) == nil {
                    return defaultValue
                }
                
                return UserDefaults.standard.bool(forKey: key) as! T
            } else
            if  T.self == String.self {
                return UserDefaults.standard.string(forKey: key) as! T
            }
            guard let data = UserDefaults.standard.object(forKey: key) as? Data else {
                return defaultValue
            }
            
            let value = try? JSONDecoder().decode(T.self, from: data)
            return value ?? defaultValue
        }
        set {
            if let flag = newValue as? Bool {
                UserDefaults.standard.setValue(flag, forKey: key)
            } else
            if let str = newValue as? String {
                UserDefaults.standard.setValue(str, forKey: key)
            } else {
                do {
                    let data = try JSONEncoder().encode(newValue)
                    UserDefaults.standard.set(data, forKey: key)
                }
                catch {
                    debugPrint("DefaultsStorage Error: \(error)")
                    UserDefaults.standard.removeObject(forKey: key)
                }
            }
            UserDefaults.standard.synchronize()
        }
    }
}

public extension DefaultsStorage where T: ExpressibleByNilLiteral {
    init(key: String) {
        self.init(key: key, defaultValue: nil)
    }
}
