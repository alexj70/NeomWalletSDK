// https://www.advancedswift.com/secure-private-data-keychain-swift/#read-data-from-keychain
// https://developer.apple.com/documentation/security/keychain_services/keychain_items/adding_a_password_to_the_keychain


import Security
import Foundation

final class KeychainInterface {
    enum KeychainError: Error {
        // Attempted read for an item that does not exist.
        case itemNotFound
        
        // Attempted save to override an existing item.
        // Use update instead of save to update existing items
        case duplicateItem
        
        // A read of an item in any format other than Data
        case invalidItemFormat
        
        // Any operation result status than errSecSuccess
        case unexpectedStatus(OSStatus)
    }
}

extension KeychainInterface {
    static func save(password: Data, service: String, account: String) throws {

        let query: [String: AnyObject] = [
            // kSecAttrService,  kSecAttrAccount, and kSecClass
            // uniquely identify the item to save in Keychain
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: account as AnyObject,
            kSecClass as String: kSecClassGenericPassword,
//            kSecClass as String: kSecClassInternetPassword,
            
            // kSecValueData is the item value to save
            kSecValueData as String: password as AnyObject,
//            kSecAttrSynchronizable as String: kCFBooleanTrue
        ]
        
        // SecItemAdd attempts to add the item identified by
        // the query to keychain
        let status = SecItemAdd(
            query as CFDictionary,
            nil
        )

        // errSecDuplicateItem is a special case where the
        // item identified by the query already exists. Throw
        // duplicateItem so the client can determine whether
        // or not to handle this as an error
        if status == errSecDuplicateItem {
            throw KeychainError.duplicateItem
        }

        // Any status other than errSecSuccess indicates the
        // save operation failed.
        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }
    }
    
    static func update(password: Data, service: String, account: String) throws {
        let query: [String: AnyObject] = [
            // kSecAttrService,  kSecAttrAccount, and kSecClass
            // uniquely identify the item to update in Keychain
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: account as AnyObject,
//            kSecClass as String: kSecClassGenericPassword,
            kSecAttrSynchronizable as String: kCFBooleanTrue
        ]
        
        // attributes is passed to SecItemUpdate with
        // kSecValueData as the updated item value
        let attributes: [String: AnyObject] = [
            kSecValueData as String: password as AnyObject
        ]
        
        // SecItemUpdate attempts to update the item identified
        // by query, overriding the previous value
        let status = SecItemUpdate(
            query as CFDictionary,
            attributes as CFDictionary
        )

        // errSecItemNotFound is a special status indicating the
        // item to update does not exist. Throw itemNotFound so
        // the client can determine whether or not to handle
        // this as an error
        guard status != errSecItemNotFound else {
            throw KeychainError.itemNotFound
        }

        // Any status other than errSecSuccess indicates the
        // update operation failed.
        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }
    }
    
    static func readPassword(service: String, account: String) throws -> Data? {
        let query: [String: AnyObject] = [
            // kSecAttrService,  kSecAttrAccount, and kSecClass
            // uniquely identify the item to read in Keychain
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: account as AnyObject,
//            kSecClass as String: kSecClassGenericPassword,
            
            // kSecMatchLimitOne indicates keychain should read
            // only the most recent item matching this query
            kSecMatchLimit as String: kSecMatchLimitOne,

            // kSecReturnData is set to kCFBooleanTrue in order
            // to retrieve the data for the item
            kSecReturnData as String: kCFBooleanTrue,
            
            // Sync Keychain With iCloud
            kSecAttrSynchronizable as String: kCFBooleanTrue
        ]

        // SecItemCopyMatching will attempt to copy the item
        // identified by query to the reference itemCopy
        var itemCopy: AnyObject?
        let status = SecItemCopyMatching(
            query as CFDictionary,
            &itemCopy
        )

        // errSecItemNotFound is a special status indicating the
        // read item does not exist. Throw itemNotFound so the
        // client can determine whether or not to handle
        // this case
        guard status != errSecItemNotFound else {
            throw KeychainError.itemNotFound
        }
        
        // Any status other than errSecSuccess indicates the
        // read operation failed.
        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }

        // This implementation of KeychainInterface requires all
        // items to be saved and read as Data. Otherwise,
        // invalidItemFormat is thrown
        guard let password = itemCopy as? Data else {
            return nil
        }

        return password
    }
    
    static func deletePassword(service: String, account: String) throws {
        let query: [String: AnyObject] = [
            // kSecAttrService,  kSecAttrAccount, and kSecClass
            // uniquely identify the item to delete in Keychain
//            kSecClass as String: kSecClassInternetPassword,
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: account as AnyObject,
            kSecClass as String: kSecClassGenericPassword
//            kSecAttrSynchronizable as String: kCFBooleanTrue
        ]

        // SecItemDelete attempts to perform a delete operation
        // for the item identified by query. The status indicates
        // if the operation succeeded or failed.
        let status = SecItemDelete(query as CFDictionary)

        // Any status other than errSecSuccess indicates the
        // delete operation failed.
        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }
        
//        let dd = KeychainSwift()
    }
}


/**
A collection of helper functions for saving text and data in the keychain.
*/
open class KeychainSwift {
  
  var lastQueryParameters: [String: Any]? // Used by the unit tests
  
  /// Contains result code from the last operation. Value is noErr (0) for a successful result.
  open var lastResultCode: OSStatus = noErr

  var keyPrefix = "" // Can be useful in test.
  
  /**
  Specify an access group that will be used to access keychain items. Access groups can be used to share keychain items between applications. When access group value is nil all application access groups are being accessed. Access group name is used by all functions: set, get, delete and clear.
  */
  open var accessGroup: String?
  
  
  /**
   
  Specifies whether the items can be synchronized with other devices through iCloud. Setting this property to true will
   add the item to other devices with the `set` method and obtain synchronizable items with the `get` command. Deleting synchronizable items will remove them from all devices. In order for keychain synchronization to work the user must enable "Keychain" in iCloud settings.
   
  Does not work on macOS.
   
  */
  open var synchronizable: Bool = false

  private let lock = NSLock()

  
  /// Instantiate a KeychainSwift object
  public init() { }
  
  /**
  
  - parameter keyPrefix: a prefix that is added before the key in get/set methods. Note that `clear` method still clears everything from the Keychain.
  */
  public init(keyPrefix: String) {
    self.keyPrefix = keyPrefix
  }
  
  /**
  
  Stores the text value in the keychain item under the given key.
  
  - parameter key: Key under which the text value is stored in the keychain.
  - parameter value: Text string to be written to the keychain.
  - parameter withAccess: Value that indicates when your app needs access to the text in the keychain item. By default the .AccessibleWhenUnlocked option is used that permits the data to be accessed only while the device is unlocked by the user.
   
   - returns: True if the text was successfully written to the keychain.
  */
  @discardableResult
  open func set(_ value: String, forKey key: String,
                  withAccess access: KeychainSwiftAccessOptions? = nil) -> Bool {
    
    if let value = value.data(using: String.Encoding.utf8) {
      return set(value, forKey: key, withAccess: access)
    }
    
    return false
  }

  /**
  
  Stores the data in the keychain item under the given key.
  
  - parameter key: Key under which the data is stored in the keychain.
  - parameter value: Data to be written to the keychain.
  - parameter withAccess: Value that indicates when your app needs access to the text in the keychain item. By default the .AccessibleWhenUnlocked option is used that permits the data to be accessed only while the device is unlocked by the user.
  
  - returns: True if the text was successfully written to the keychain.
  
  */
  @discardableResult
  open func set(_ value: Data, forKey key: String,
    withAccess access: KeychainSwiftAccessOptions? = nil) -> Bool {
    
    // The lock prevents the code to be run simultaneously
    // from multiple threads which may result in crashing
    lock.lock()
    defer { lock.unlock() }
    
    deleteNoLock(key) // Delete any existing key before saving it
    let accessible = access?.value ?? KeychainSwiftAccessOptions.defaultOption.value
      
    let prefixedKey = keyWithPrefix(key)
      
    var query: [String : Any] = [
      KeychainSwiftConstants.klass       : kSecClassGenericPassword,
      KeychainSwiftConstants.attrAccount : prefixedKey,
      KeychainSwiftConstants.valueData   : value,
      KeychainSwiftConstants.accessible  : accessible
    ]
      
    query = addAccessGroupWhenPresent(query)
    query = addSynchronizableIfRequired(query, addingItems: true)
    lastQueryParameters = query
    
    lastResultCode = SecItemAdd(query as CFDictionary, nil)
    
    return lastResultCode == noErr
  }

  /**
  Stores the boolean value in the keychain item under the given key.
  - parameter key: Key under which the value is stored in the keychain.
  - parameter value: Boolean to be written to the keychain.
  - parameter withAccess: Value that indicates when your app needs access to the value in the keychain item. By default the .AccessibleWhenUnlocked option is used that permits the data to be accessed only while the device is unlocked by the user.
  - returns: True if the value was successfully written to the keychain.
  */
  @discardableResult
  open func set(_ value: Bool, forKey key: String,
    withAccess access: KeychainSwiftAccessOptions? = nil) -> Bool {
  
    let bytes: [UInt8] = value ? [1] : [0]
    let data = Data(bytes)

    return set(data, forKey: key, withAccess: access)
  }

  /**
  
  Retrieves the text value from the keychain that corresponds to the given key.
  
  - parameter key: The key that is used to read the keychain item.
  - returns: The text value from the keychain. Returns nil if unable to read the item.
  
  */
  open func get(_ key: String) -> String? {
    if let data = getData(key) {
      
      if let currentString = String(data: data, encoding: .utf8) {
        return currentString
      }
      
      lastResultCode = -67853 // errSecInvalidEncoding
    }

    return nil
  }

  /**
  
  Retrieves the data from the keychain that corresponds to the given key.
  
  - parameter key: The key that is used to read the keychain item.
  - parameter asReference: If true, returns the data as reference (needed for things like NEVPNProtocol).
  - returns: The text value from the keychain. Returns nil if unable to read the item.
  
  */
  open func getData(_ key: String, asReference: Bool = false) -> Data? {
    // The lock prevents the code to be run simultaneously
    // from multiple threads which may result in crashing
    lock.lock()
    defer { lock.unlock() }
    
    let prefixedKey = keyWithPrefix(key)
    
    var query: [String: Any] = [
      KeychainSwiftConstants.klass       : kSecClassGenericPassword,
      KeychainSwiftConstants.attrAccount : prefixedKey,
      KeychainSwiftConstants.matchLimit  : kSecMatchLimitOne
    ]
    
    if asReference {
      query[KeychainSwiftConstants.returnReference] = kCFBooleanTrue
    } else {
      query[KeychainSwiftConstants.returnData] =  kCFBooleanTrue
    }
    
    query = addAccessGroupWhenPresent(query)
    query = addSynchronizableIfRequired(query, addingItems: false)
    lastQueryParameters = query
    
    var result: AnyObject?
    
    lastResultCode = withUnsafeMutablePointer(to: &result) {
      SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
    }
    
    if lastResultCode == noErr {
      return result as? Data
    }
    
    return nil
  }

  /**
  Retrieves the boolean value from the keychain that corresponds to the given key.
  - parameter key: The key that is used to read the keychain item.
  - returns: The boolean value from the keychain. Returns nil if unable to read the item.
  */
  open func getBool(_ key: String) -> Bool? {
    guard let data = getData(key) else { return nil }
    guard let firstBit = data.first else { return nil }
    return firstBit == 1
  }

  /**
  Deletes the single keychain item specified by the key.
  
  - parameter key: The key that is used to delete the keychain item.
  - returns: True if the item was successfully deleted.
  
  */
  @discardableResult
  open func delete(_ key: String) -> Bool {
    // The lock prevents the code to be run simultaneously
    // from multiple threads which may result in crashing
    lock.lock()
    defer { lock.unlock() }
    
    return deleteNoLock(key)
  }
  
  /**
  Return all keys from keychain
   
  - returns: An string array with all keys from the keychain.
   
  */
  public var allKeys: [String] {
    var query: [String: Any] = [
      KeychainSwiftConstants.klass : kSecClassGenericPassword,
      KeychainSwiftConstants.returnData : true,
      KeychainSwiftConstants.returnAttributes: true,
      KeychainSwiftConstants.returnReference: true,
      KeychainSwiftConstants.matchLimit: KeychainSwiftConstants.secMatchLimitAll
    ]
  
    query = addAccessGroupWhenPresent(query)
    query = addSynchronizableIfRequired(query, addingItems: false)

    var result: AnyObject?

    let lastResultCode = withUnsafeMutablePointer(to: &result) {
      SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
    }
    
    if lastResultCode == noErr {
      return (result as? [[String: Any]])?.compactMap {
        $0[KeychainSwiftConstants.attrAccount] as? String } ?? []
    }
    
    return []
  }
    
  /**
   
  Same as `delete` but is only accessed internally, since it is not thread safe.
   
   - parameter key: The key that is used to delete the keychain item.
   - returns: True if the item was successfully deleted.
   
   */
  @discardableResult
  func deleteNoLock(_ key: String) -> Bool {
    let prefixedKey = keyWithPrefix(key)
    
    var query: [String: Any] = [
      KeychainSwiftConstants.klass       : kSecClassGenericPassword,
      KeychainSwiftConstants.attrAccount : prefixedKey
    ]
    
    query = addAccessGroupWhenPresent(query)
    query = addSynchronizableIfRequired(query, addingItems: false)
    lastQueryParameters = query
    
    lastResultCode = SecItemDelete(query as CFDictionary)
    
    return lastResultCode == noErr
  }

  /**
  
  Deletes all Keychain items used by the app. Note that this method deletes all items regardless of the prefix settings used for initializing the class.
  
  - returns: True if the keychain items were successfully deleted.
  
  */
  @discardableResult
  open func clear() -> Bool {
    // The lock prevents the code to be run simultaneously
    // from multiple threads which may result in crashing
    lock.lock()
    defer { lock.unlock() }
    
    var query: [String: Any] = [ kSecClass as String : kSecClassGenericPassword ]
    query = addAccessGroupWhenPresent(query)
    query = addSynchronizableIfRequired(query, addingItems: false)
    lastQueryParameters = query
    
    lastResultCode = SecItemDelete(query as CFDictionary)
    
    return lastResultCode == noErr
  }
  
  /// Returns the key with currently set prefix.
  func keyWithPrefix(_ key: String) -> String {
    return "\(keyPrefix)\(key)"
  }
  
  func addAccessGroupWhenPresent(_ items: [String: Any]) -> [String: Any] {
    guard let accessGroup = accessGroup else { return items }
    
    var result: [String: Any] = items
    result[KeychainSwiftConstants.accessGroup] = accessGroup
    return result
  }
  
  /**
 
  Adds kSecAttrSynchronizable: kSecAttrSynchronizableAny` item to the dictionary when the `synchronizable` property is true.
   
   - parameter items: The dictionary where the kSecAttrSynchronizable items will be added when requested.
   - parameter addingItems: Use `true` when the dictionary will be used with `SecItemAdd` method (adding a keychain item). For getting and deleting items, use `false`.
   
   - returns: the dictionary with kSecAttrSynchronizable item added if it was requested. Otherwise, it returns the original dictionary.
 
  */
  func addSynchronizableIfRequired(_ items: [String: Any], addingItems: Bool) -> [String: Any] {
    if !synchronizable { return items }
    var result: [String: Any] = items
    result[KeychainSwiftConstants.attrSynchronizable] = addingItems == true ? true : kSecAttrSynchronizableAny
    return result
  }
}



public enum KeychainSwiftAccessOptions {
  
  /**
  
  The data in the keychain item can be accessed only while the device is unlocked by the user.
  
  This is recommended for items that need to be accessible only while the application is in the foreground. Items with this attribute migrate to a new device when using encrypted backups.
  
  This is the default value for keychain items added without explicitly setting an accessibility constant.
  
  */
  case accessibleWhenUnlocked
  
  /**
  
  The data in the keychain item can be accessed only while the device is unlocked by the user.
  
  This is recommended for items that need to be accessible only while the application is in the foreground. Items with this attribute do not migrate to a new device. Thus, after restoring from a backup of a different device, these items will not be present.
  
  */
  case accessibleWhenUnlockedThisDeviceOnly
  
  /**
  
  The data in the keychain item cannot be accessed after a restart until the device has been unlocked once by the user.
  
  After the first unlock, the data remains accessible until the next restart. This is recommended for items that need to be accessed by background applications. Items with this attribute migrate to a new device when using encrypted backups.
  
  */
  case accessibleAfterFirstUnlock
  
  /**
  
  The data in the keychain item cannot be accessed after a restart until the device has been unlocked once by the user.
  
  After the first unlock, the data remains accessible until the next restart. This is recommended for items that need to be accessed by background applications. Items with this attribute do not migrate to a new device. Thus, after restoring from a backup of a different device, these items will not be present.
  
  */
  case accessibleAfterFirstUnlockThisDeviceOnly

  /**
  
  The data in the keychain can only be accessed when the device is unlocked. Only available if a passcode is set on the device.
  
  This is recommended for items that only need to be accessible while the application is in the foreground. Items with this attribute never migrate to a new device. After a backup is restored to a new device, these items are missing. No items can be stored in this class on devices without a passcode. Disabling the device passcode causes all items in this class to be deleted.
  
  */
  case accessibleWhenPasscodeSetThisDeviceOnly
  
  static var defaultOption: KeychainSwiftAccessOptions {
    return .accessibleWhenUnlocked
  }
  
  var value: String {
    switch self {
    case .accessibleWhenUnlocked:
      return toString(kSecAttrAccessibleWhenUnlocked)
      
    case .accessibleWhenUnlockedThisDeviceOnly:
      return toString(kSecAttrAccessibleWhenUnlockedThisDeviceOnly)
      
    case .accessibleAfterFirstUnlock:
      return toString(kSecAttrAccessibleAfterFirstUnlock)
      
    case .accessibleAfterFirstUnlockThisDeviceOnly:
      return toString(kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly)
      
    case .accessibleWhenPasscodeSetThisDeviceOnly:
      return toString(kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly)
    }
  }
  
  func toString(_ value: CFString) -> String {
    return KeychainSwiftConstants.toString(value)
  }
}


/// Constants used by the library
public struct KeychainSwiftConstants {
  /// Specifies a Keychain access group. Used for sharing Keychain items between apps.
  public static var accessGroup: String { return toString(kSecAttrAccessGroup) }
  
  /**
   
   A value that indicates when your app needs access to the data in a keychain item. The default value is AccessibleWhenUnlocked. For a list of possible values, see KeychainSwiftAccessOptions.
   
   */
  public static var accessible: String { return toString(kSecAttrAccessible) }
  
  /// Used for specifying a String key when setting/getting a Keychain value.
  public static var attrAccount: String { return toString(kSecAttrAccount) }

  /// Used for specifying synchronization of keychain items between devices.
  public static var attrSynchronizable: String { return toString(kSecAttrSynchronizable) }
  
  /// An item class key used to construct a Keychain search dictionary.
  public static var klass: String { return toString(kSecClass) }
  
  /// Specifies the number of values returned from the keychain. The library only supports single values.
  public static var matchLimit: String { return toString(kSecMatchLimit) }
  
  /// A return data type used to get the data from the Keychain.
  public static var returnData: String { return toString(kSecReturnData) }
  
  /// Used for specifying a value when setting a Keychain value.
  public static var valueData: String { return toString(kSecValueData) }
    
  /// Used for returning a reference to the data from the keychain
  public static var returnReference: String { return toString(kSecReturnPersistentRef) }
  
  /// A key whose value is a Boolean indicating whether or not to return item attributes
  public static var returnAttributes : String { return toString(kSecReturnAttributes) }
    
  /// A value that corresponds to matching an unlimited number of items
  public static var secMatchLimitAll : String { return toString(kSecMatchLimitAll) }
    
  static func toString(_ value: CFString) -> String {
    return value as String
  }
}


