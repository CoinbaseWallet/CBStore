// Copyright (c) 2017-2019 Coinbase Inc. See LICENSE

import Foundation

/// Storage for user defaults
final class MemoryStorage: Storage {
    private let accessQueue = DispatchQueue(label: "memoryStorageQueue", qos: .userInitiated, attributes: .concurrent)
    private var cache = [String: Any]()

    func set(_ key: String, value: Any?) {
        accessQueue.async(flags: .barrier) {
            self.cache[key] = value
        }
    }

    func get(_ key: String) -> Any? {
        var result: Any?

        accessQueue.sync {
            result = self.cache[key]
        }

        return result
    }

    func destroy() {
        cache.removeAll()
    }
}
