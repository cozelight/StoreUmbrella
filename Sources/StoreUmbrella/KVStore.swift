import UIKit

public protocol KVStoreAction: AnyObject {
    func removeObject(forKey key: String)
    func data(forKey key: String) -> Data?
    func integer(forKey key: String) -> Int?
    func float(forKey key: String) -> Float?
    func double(forKey key: String) -> Double?
    func bool(forKey key: String) -> Bool?
    func string(forKey key: String) -> String?
    func store(type: KVStoreActionType, forKey key: String)
}

public enum KVStoreActionType {
    case int(value: Int)
    case double(value: Double)
    case float(value: Float)
    case string(value: String)
    case bool(value: Bool)
    case data(value: Data)
}

private enum KVType {
    case int(value: Int)
    case double(value: Double)
    case float(value: Float)
    case string(value: String)
    case bool(value: Bool)
    case data(value: Data)
    case codable(object: Codable, data: () -> Data?)
    
    var actionType: KVStoreActionType {
        switch self {
        case .int(value: let value):
            return .int(value: value)
        case .double(value: let value):
            return .double(value: value)
        case .float(value: let value):
            return .float(value: value)
        case .string(value: let value):
            return .string(value: value)
        case .bool(value: let value):
            return .bool(value: value)
        case .data(value: let value):
            return .data(value: value)
        case .codable(object: _, data: let data):
            return .data(value: data() ?? Data())
        }
    }
}

public class KVStore {
    struct KVEmpty {}
    
    public static let shared = KVStore()
    public weak var custom: KVStoreAction?
    private var cache: [String: Any] = [:]
    private let queue = DispatchQueue(label: "KVStore", attributes: .concurrent)
    
    public func set(_ value: String?, forKey key: String) {
        if let value = value {
            set(type: .string(value: value), forKey: key)
        }
        else {
            removeObject(forKey: key)
        }
    }
    
    public func set(_ value: Int?, forKey key: String) {
        if let value = value {
            set(type: .int(value: value), forKey: key)
        }
        else {
            removeObject(forKey: key)
        }
    }
    
    public func set(_ value: Double?, forKey key: String) {
        if let value = value {
            set(type: .double(value: value), forKey: key)
        }
        else {
            removeObject(forKey: key)
        }
    }
    
    public func set(_ value: Float?, forKey key: String) {
        if let value = value {
            set(type: .float(value: value), forKey: key)
        }
        else {
            removeObject(forKey: key)
        }
    }
    
    public func set(_ value: Data?, forKey key: String) {
        if let value = value {
            set(type: .data(value: value), forKey: key)
        }
        else {
            removeObject(forKey: key)
        }
    }
    
    public func set(_ value: Bool?, forKey key: String) {
        if let value = value {
            set(type: .bool(value: value), forKey: key)
        }
        else {
            removeObject(forKey: key)
        }
    }
    
    public func set<T>(_ value: T?, forKey key: String) where T: Codable {
        if let value = value {
            set(type: .codable(object: value, data: {try? JSONEncoder().encode(value)}), forKey: key)
        }
        else {
            removeObject(forKey: key)
        }
    }
    
    public func removeObject(forKey key: String) {
        setCache(value: KVEmpty(), forKey: key)
        if custom == nil {
            UserDefaults.standard.removeObject(forKey: key)
        }
        else {
            custom?.removeObject(forKey: key)
        }
    }
}

extension KVStore {
    private func value<T>(forKey key: String, getValue: ((String)->T?) )->T? {
        if let value = cacheValue(forKey: key) as? T {
            return value
        }
        if cacheValue(forKey: key) is KVEmpty {
            return nil
        }
        let result = getValue(key)
        if let result = result {
            setCache(value: result, forKey: key)
        }
        else {
            setCache(value: KVEmpty(), forKey: key)
        }
        return result
    }
    
    public func data(forKey key: String) -> Data? {
        return value(forKey: key) { key in
            if custom == nil {
                return UserDefaults.standard.data(forKey: key)
            }
            else {
                return custom?.data(forKey: key)
            }
        }
    }
    
    public func integer(forKey key: String) -> Int? {
        return value(forKey: key) { key in
            if custom == nil {
                return UserDefaults.standard.object(forKey: key) as? Int
            }
            else {
                return custom?.integer(forKey: key)
            }
        }
    }
    
    public func integer(forKey key: String, defaultValue: Int) -> Int {
        return integer(forKey: key) ?? defaultValue
    }
    
    public func float(forKey key: String) -> Float? {
        return value(forKey: key) { key in
            if custom == nil {
                return UserDefaults.standard.object(forKey: key) as? Float
            }
            else {
                return custom?.float(forKey: key)
            }
        }
    }
    
    public func float(forKey key: String, defaultValue: Float) -> Float {
        return float(forKey: key) ?? defaultValue
    }
    
    public func double(forKey key: String) -> Double? {
        return value(forKey: key) { key in
            if custom == nil {
                return UserDefaults.standard.object(forKey: key) as? Double
            }
            else {
                return custom?.double(forKey: key)
            }
        }
    }
    
    public func double(forKey key: String, defaultValue: Double) -> Double {
        return double(forKey: key) ?? defaultValue
    }
    
    public func bool(forKey key: String) -> Bool? {
        return value(forKey: key) { key in
            if custom == nil {
                return UserDefaults.standard.object(forKey: key) as? Bool
            }
            else {
                return custom?.bool(forKey: key)
            }
        }
    }
    
    public func bool(forKey key: String, defaultValue: Bool) -> Bool {
        return bool(forKey: key) ?? defaultValue
    }
    
    public func string(forKey key: String) -> String? {
        return value(forKey: key) { key in
            if custom == nil {
                return UserDefaults.standard.string(forKey: key)
            }
            else {
                return custom?.string(forKey: key)
            }
        }
    }
    
    public func string(forKey key: String, defaultValue: String) -> String {
        return string(forKey: key) ?? defaultValue
    }
    
    public func codable<T>(forKey key: String) -> T? where T: Codable {
        return value(forKey: key) { key in
            var result: T?
            if let data = data(forKey: key) {
               result = try? JSONDecoder().decode(T.self, from: data)
            }
            return result
        }
    }
    
    public func codable<T>(forKey key: String, defaultValue: T) -> T where T: Codable {
        return codable(forKey: key) ?? defaultValue
    }
}

extension KVStore {
    private func setCache(withType type: KVType, forKey key: String) {
        switch type {
        case .int(let value):
            setCache(value: value, forKey: key)
        case .double(let value):
            setCache(value: value, forKey: key)
        case .float(let value):
            setCache(value: value, forKey: key)
        case .string(let value):
            setCache(value: value, forKey: key)
        case .data(let value):
            setCache(value: value, forKey: key)
        case .bool(let value):
            setCache(value: value, forKey: key)
        case .codable(let object, _):
            setCache(value: object, forKey: key)
        }
    }
    
    private func cacheValue(forKey key: String) -> Any? {
        var value: Any?
        queue.sync {
            value = cache[key]
        }
        
        return value
    }
    
    private func setCache(value: Any, forKey key: String) {
        queue.async(flags: .barrier) {
            self.cache[key] = value
        }
    }
}

extension KVStore {
    private func set(type: KVType, forKey key: String) {
        setCache(withType: type, forKey: key)
        store(type: type, forKey: key)
    }
    
    private func store(type: KVType, forKey key: String) {
        if custom == nil {
            switch type {
            case .int(let value):
                UserDefaults.standard.set(value, forKey: key)
            case .double(let value):
                UserDefaults.standard.set(value, forKey: key)
            case .float(let value):
                UserDefaults.standard.set(value, forKey: key)
            case .string(let value):
                UserDefaults.standard.set(value, forKey: key)
            case .data(let value):
                UserDefaults.standard.set(value, forKey: key)
            case .bool(let value):
                UserDefaults.standard.set(value, forKey: key)
            case .codable(_, data: let getData):
                UserDefaults.standard.set(getData(), forKey: key)
            }
        }
        else {
            custom?.store(type: type.actionType, forKey: key)
        }
    }
}
