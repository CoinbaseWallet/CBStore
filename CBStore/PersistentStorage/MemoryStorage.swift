// Copyright (c) 2017-2019 Coinbase Inc. See LICENSE

import Foundation

/// Storage for user defaults
final class MemoryStorage: Storage {
    private var cache = [String: Any]()

    func set(_ key: String, value: Any?) {
        cache[key] = value
    }

    func get(_ key: String) -> Any? {
        return cache[key]
    }

    func destroy() {
        cache.removeAll()
    }
}
