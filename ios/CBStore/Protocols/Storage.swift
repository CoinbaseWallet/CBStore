// Copyright (c) 2017-2019 Coinbase Inc. See LICENSE

import Foundation

/// This protocol declares all operations required from the storage impl
protocol Storage {
    /// Store value for key
    ///
    /// - parameter key: Key used to store value
    /// - parameter value: Value to be stored. If nil is passed, the entry will be removed.
    func set(_ key: String, value: Any?)

    /// Get value by key
    ///
    /// - parameter key: Key to use to get value
    ///
    /// - returns: The stored value if available. Otherwise, nil
    func get(_ key: String) -> Any?

    /// Delete all keys in storage
    func destroy()

    /// If supported, persist changes to disk immediat. Otherwise, it's a noop
    func sync()
}
