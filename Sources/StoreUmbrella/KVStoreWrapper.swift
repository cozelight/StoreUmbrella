import Foundation

/// PropertyWrapper for KVStore type
///
///     @KVStoreWrapper(rawKey: "123", defaultValue: 0)
///     public var someInt: Int
///
///     @KVStoreWrapper(key: SomeEnum.someKey, defaultValue: 0)
///     public var someInt: Int
///
///     @KVStoreWrapper(key: SomeEnum.someKey)
///     public var someInt: Int?
///
///     @KVStoreWrapper(key: SomeEnum.someKey, defaultValue: 0)
///     public var someInt: Int?
///
///     @KVStoreWrapper(key: SomeEnum.someKey, defaultValue: nil)
///     public var someInt: Int?
@propertyWrapper public struct KVStoreWrapper<ValueType: Codable> {
    let key: String
    let defaultValue: ValueType
    
    public init(rawKey: String, defaultValue: ValueType) {
        self.key = rawKey
        self.defaultValue = defaultValue
    }
    
    public init<Wrapped>(rawKey: String, defaultValue: Wrapped) where ValueType == Optional<Wrapped> {
        self.key = rawKey
        self.defaultValue = defaultValue
    }
    
    public init<Wrapped>(rawKey: String) where ValueType == Optional<Wrapped> {
        self.key = rawKey
        self.defaultValue = Optional<Wrapped>.none
    }
    
    public init(key: KVStoreKey, defaultValue: ValueType) {
        self.key = key.key
        self.defaultValue = defaultValue
    }
    
    public init<Wrapped>(key: KVStoreKey, defaultValue: Wrapped) where ValueType == Optional<Wrapped> {
        self.key = key.key
        self.defaultValue = defaultValue
    }
    
    public init<Wrapped>(key: KVStoreKey) where ValueType == Optional<Wrapped> {
        self.key = key.key
        self.defaultValue = Optional<Wrapped>.none
    }

    public var wrappedValue: ValueType {
        get {
            if let type = ValueType.self as? _OptionalProtocol.Type,
                let wrapped = type.wrappedType as? _KVStoreBasicType.Type {
                if let value = wrapped.getSelf(forKey: key) as? ValueType, deepUnwrap(value) != nil {
                    return value
                }
            }
            else {
                guard let type = ValueType.self as? _KVStoreBasicType.Type else {
                    return KVStore.shared.codable(forKey: key, defaultValue: defaultValue)
                }
                if let value = type.getSelf(forKey: key) as? ValueType, deepUnwrap(value) != nil {
                    return value
                }
            }
            return defaultValue
        }
        set {
            guard let new = newValue as? _KVStoreBasicType else {
                KVStore.shared.set(newValue, forKey: key)
                return
            }
            new.setSelf(forKey: key)
        }
    }
}

// MARK: For BasicType
private protocol _KVStoreBasicType{
    func setSelf(forKey key: String)
    static func getSelf(forKey key: String)->Self?
}
extension Data: _KVStoreBasicType {
    func setSelf(forKey key: String) {
        KVStore.shared.set(self, forKey: key)
    }
    static func getSelf(forKey key: String)->Self? {
        return KVStore.shared.data(forKey: key)
    }
}
extension String: _KVStoreBasicType {
    func setSelf(forKey key: String) {
        KVStore.shared.set(self, forKey: key)
    }
    static func getSelf(forKey key: String)->Self? {
        return KVStore.shared.string(forKey: key)
    }
}
extension Bool: _KVStoreBasicType {
    func setSelf(forKey key: String) {
        KVStore.shared.set(self, forKey: key)
    }
    static func getSelf(forKey key: String)->Self? {
        return KVStore.shared.bool(forKey: key)
    }
}
extension Int: _KVStoreBasicType {
    func setSelf(forKey key: String) {
        KVStore.shared.set(self, forKey: key)
    }
    static func getSelf(forKey key: String)->Self? {
        return KVStore.shared.integer(forKey: key)
    }
}
extension Double: _KVStoreBasicType {
    func setSelf(forKey key: String) {
        KVStore.shared.set(self, forKey: key)
    }
    static func getSelf(forKey key: String)->Self? {
        return KVStore.shared.double(forKey: key)
    }
}
extension Float: _KVStoreBasicType {
    func setSelf(forKey key: String) {
        KVStore.shared.set(self, forKey: key)
    }
    static func getSelf(forKey key: String)->Self? {
        return KVStore.shared.float(forKey: key)
    }
}


// MARK: For optional deep unwrap
private protocol _OptionalProtocol {
    var _deepUnwrapped: Any? { get }
    static var wrappedType: Any.Type { get }
}

extension Optional: _OptionalProtocol {
    fileprivate var _deepUnwrapped: Any? {
        if let wrapped = self { return deepUnwrap(wrapped) }
        return nil
    }
    
    fileprivate static var wrappedType: Any.Type {
        return Wrapped.self
    }
}

fileprivate func deepUnwrap(_ any: Any) -> Any? {
    if let optional = any as? _OptionalProtocol {
        return optional._deepUnwrapped
    }
    return any
}
