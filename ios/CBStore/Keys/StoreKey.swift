// Copyright (c) 2017-2019 Coinbase Inc. See LICENSE

import Foundation

public class StoreKey<T>: StoreKeys {
    /// Type of store. i.e. keychain vs user defaults vs cloud KeyValue store
    public let kind: StoreKind

    /// Store key name
    public let name: String

    /// Optional unique identifier for key. Typically used to target a specific key with unique id
    public let uuid: String?

    /// Stored value type
    let valueType: T.Type

    /// Determine whether to immediately sync UserDefaults to disk. Default is false
    let syncNow: Bool

    /// Constructor to create a custom store key
    ///
    /// - parameter prefixOrName: Key name or key prefix if udid is specified
    /// - parameter uuid:         Optional unique identifier
    /// - parameter kind:         Type of value to store.
    /// - parameter syncNow:      Determine whether to persist to disk immediately.
    ///
    /// - returns: A new `StoreKey` instance
    init(
        _ prefixOrName: String,
        uuid: String? = nil,
        kind: StoreKind = .userDefaults,
        syncNow: Bool = false
    ) {
        let valueType = T.self
        let pieces = [kind.rawValue, prefixOrName, uuid, "\(type(of: valueType))"]

        name = pieces.compactMap { $0 }.joined(separator: "_")
        self.valueType = valueType
        self.uuid = uuid
        self.kind = kind
        self.syncNow = syncNow
    }
}

/// Keys should add static `StoreKey` constants using extensions
public class StoreKeys {}
