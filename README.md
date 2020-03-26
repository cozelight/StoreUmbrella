# StoreUmbrella
 存储抽象层，UserDefaults 风格的 API

### 特性介绍

- 支持 UserDefaults 风格的API
- 支持设置 defaultValue
- 支持 codable 对象
- 自带内存缓存
- 实现了 propertyWrapper 的封装

### 使用说明

##### UserDefaults 风格的API

```swift
set(value, forKey: "key")

data(forKey: "key")
integer(forKey: "key")
float(forKey: "key")
double(forKey: "key")
bool(forKey: "key")
string(forKey: "key")
```

##### defaultValue 的支持

```swift
integer(forKey: "key", defaultValue: 0)
float(forKey: "key", defaultValue: 0)
double(forKey: "key", defaultValue: 0)
bool(forKey: "key", defaultValue: false)
string(forKey: "key", defaultValue: "defaultString")
codable(forKey:  "key", defaultValue: Date())
```

##### codable 的支持

```swift
codable(forKey: "key")
codable(forKey: "key", defaultValue: Date())
```

##### 避免裸字符串的Key

```swift
// SomeModuleA, SomeModuleA类似于命名空间
enum SomeModuleA: String, KVStoreKey {
	case someKeyA
	case someKeyB
}

enum SomeModuleB: String, KVStoreKey {
	case someKeyA
	case someKeyC
}

set(value, forKey: SomeModuleA.someKeyA) //真实key为"SomeModuleA.someKeyA"
integer(forKey: SomeModuleA.someKeyB) //真实key为"SomeModuleA.someKeyB"
bool(forKey: SomeModuleB.someKeyA) //真实key为"SomeModuleB.someKeyA"
string(forKey: SomeModuleB.someKeyC) //真实key为"SomeModuleB.someKeyC"
```

通过枚举形式避免了 key 的 Hardcode，同时通过枚举名引入了命名空间，可以避免不同 key 的冲突，也方便模块管理。

默认的 rawkey 为 "enum名.key名"， 有特殊需求可以通过实现 KVStoreKey 的方法来自定义真实的 rawkey。

注：如果 enum 不为 String 类型的 RawRepresentable，需要自己定义 rawkey 的实现。

##### PropertyWrapper的封装

```swift
@KVStoreWrapper(key: SomeEnum.someKey, defaultValue: 0)
public var someInt: Int

@KVStoreWrapper(key: SomeEnum.someKey)
public var someInt: Int?

@KVStoreWrapper(key: SomeEnum.someKey, defaultValue: 0)
public var someInt: Int?

@KVStoreWrapper(key: SomeEnum.someKey, defaultValue: nil)
public var someInt: Int?
```

前两种方式就可以满足绝大部分需求，后两种方式以防万一也做了实现。

