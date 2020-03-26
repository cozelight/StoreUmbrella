import Foundation

/// A key protocol use to make enum keys.
///
///     enum SomeModule: String, KVStoreKey {
///         case someKey
///     }
public protocol KVStoreKey {
    var rawKey: String { get }
    var namespace: String { get }
    var key: String { get }
}

public extension KVStoreKey {
    var namespace: String {
        return "\(Self.self)"
    }
    var key: String {
        return "\(namespace).\(rawKey)"
    }
}

public extension KVStoreKey where Self: RawRepresentable, RawValue == String {
    var rawKey: String {
        return rawValue
    }
}

public extension KVStore {
    func set(_ value: String?, forKey key: KVStoreKey) {
        set(value, forKey: key.key)
    }
    
    func set(_ value: Int?, forKey key: KVStoreKey) {
        set(value, forKey: key.key)
    }
    
    func set(_ value: Double?, forKey key: KVStoreKey) {
        set(value, forKey: key.key)
    }
    
    func set(_ value: Float?, forKey key: KVStoreKey) {
        set(value, forKey: key.key)
    }
    
    func set(_ value: Data?, forKey key: KVStoreKey) {
        set(value, forKey: key.key)
    }
    
    func set(_ value: Bool?, forKey key: KVStoreKey) {
        set(value, forKey: key.key)
    }
    
    func set<T>(_ value: T?, forKey key: KVStoreKey) where T: Codable {
        set(value, forKey: key.key)
    }
    
    func removeObject(forKey key: KVStoreKey) {
        removeObject(forKey: key.key)
    }
}

public extension KVStore {
    func data(forKey key: KVStoreKey) -> Data? {
        return data(forKey: key.key)
    }
    
    func integer(forKey key: KVStoreKey) -> Int? {
        return integer(forKey: key.key)
    }
    
    func integer(forKey key: KVStoreKey, defaultValue: Int) -> Int {
        return integer(forKey: key.key, defaultValue: defaultValue)
    }
    
    func float(forKey key: KVStoreKey) -> Float? {
        return float(forKey: key.key)
    }
    
    func float(forKey key: KVStoreKey, defaultValue: Float) -> Float {
        return float(forKey: key.key, defaultValue: defaultValue)
    }
    
    func double(forKey key: KVStoreKey) -> Double? {
        return double(forKey: key.key)
    }
    
    func double(forKey key: KVStoreKey, defaultValue: Double) -> Double {
        return double(forKey: key.key, defaultValue: defaultValue)
    }
    
    func bool(forKey key: KVStoreKey) -> Bool? {
        return bool(forKey: key.key)
    }
    
    func bool(forKey key: KVStoreKey, defaultValue: Bool) -> Bool {
        return bool(forKey: key.key, defaultValue: defaultValue)
    }
    
    func string(forKey key: KVStoreKey) -> String? {
        return string(forKey: key.key)
    }
    
    func string(forKey key: KVStoreKey, defaultValue: String) -> String {
        return string(forKey: key.key, defaultValue: defaultValue)
    }
    
    func codable<T>(forKey key: KVStoreKey) -> T? where T: Codable {
        return codable(forKey: key.key)
    }
    
    func codable<T>(forKey key: KVStoreKey, defaultValue: T) -> T where T: Codable {
        return codable(forKey: key.key, defaultValue: defaultValue)
    }
}
