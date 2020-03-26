//
//  Demo.swift
//  Example
//
//  Created by ganzhen on 2020/3/26.
//  Copyright © 2020 ganzhen. All rights reserved.
//

import StoreUmbrella

enum ModuleAKeys: String, KVStoreKey {
    case firstKey
    case secondKey
}

enum ModuleBKeys: String, KVStoreKey {
    case firstKey
    case thirdKey
}

let defaultDate = Date()

class Demo {
    //Recommend
    @KVStoreWrapper(rawKey: "1234")
    var someIntA: Int?

    //Recommend
    @KVStoreWrapper(rawKey: "2234", defaultValue: 0)
    var someIntB: Int

    //In case you need
    @KVStoreWrapper(rawKey: "3234", defaultValue: nil)
    var someIntC: Int?

    //In case you need
    @KVStoreWrapper(rawKey: "4234", defaultValue: nil)
    var someIntD: Int?


    //Recommend
    @KVStoreWrapper(key: ModuleAKeys.firstKey)
    var someDateA: Date?

    //Recommend
    @KVStoreWrapper(key: ModuleAKeys.secondKey, defaultValue: defaultDate)
    var someDateB: Date

    //In case you need
    @KVStoreWrapper(key: ModuleBKeys.firstKey, defaultValue: nil)
    var someDateC: Date?

    //In case you need
    @KVStoreWrapper(key: ModuleBKeys.thirdKey, defaultValue: defaultDate)
    var someDateD: Date?

    func test() {
        clearUserDefaults()

        assert(someIntA == nil)
        someIntA = 0
        assert(someIntA == 0)
        someIntA = nil
        assert(someIntA == nil)

        assert(someIntB == 0)
        someIntB = 10
        assert(someIntB == 10)

        assert(someIntC == nil)
        someIntC = 1
        assert(someIntC == 1)
        someIntC = nil
        assert(someIntC == nil)

        someIntD = 5
        assert(someIntD == 5)
        someIntD = nil
        assert(someIntD == nil)

        let anotherDate = Date()
        assert(someDateA == nil)
        someDateA = anotherDate
        assert(someDateA == anotherDate)
        someDateA = nil
        assert(someDateA == nil)

        assert(someDateB == defaultDate)
        someDateB = anotherDate
        assert(someDateB == anotherDate)

        assert(someDateC == nil)
        someDateC = anotherDate
        assert(someDateC == anotherDate)
        someDateC = nil
        assert(someDateC == nil)

        someDateD = anotherDate
        assert(someDateD == anotherDate)
        someDateD = nil
        assert(someDateD == nil)
    }
}

func clearUserDefaults() {
    let libPath = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first!)
    let defaultsPath = libPath.appendingPathComponent("Preferences").appendingPathComponent("\(Bundle.main.bundleIdentifier ?? "").plist")

    guard FileManager.default.fileExists(atPath: defaultsPath.path) else {return}

    let dict = NSDictionary(contentsOfFile: defaultsPath.path)

    guard let keys = dict?.allKeys else {return}

    keys.forEach { (key) in
        guard let str = key as? String else { return }
        UserDefaults.standard.removeObject(forKey: str)
    }
    UserDefaults.standard.synchronize()

}
