// Copyright (c) 2017-2019 Coinbase Inc. See LICENSE

import Foundation

/// Storage for iCloud key-value store
struct CloudStorage: Storage {
    func set(_ key: String, value: Any?) {
        if let value = value {
            return NSUbiquitousKeyValueStore.default.set(value, forKey: key)
        } else if value == nil {
            return NSUbiquitousKeyValueStore.default.removeObject(forKey: key)
        }
    }

    func get(_ key: String) -> Any? {
        return NSUbiquitousKeyValueStore.default.object(forKey: key)
    }

    func sync() {
        _ = NSUbiquitousKeyValueStore.default.synchronize()
    }

    func destroy() {
        let keys = NSUbiquitousKeyValueStore.default.dictionaryRepresentation.keys

        keys.forEach { NSUbiquitousKeyValueStore.default.removeObject(forKey: $0) }
    }
}
