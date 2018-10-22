// Copyright (c) 2017-2018 Coinbase Inc. See LICENSE

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

    /// Constructor to create a custom store key
    ///
    /// - parameter prefixOrName:           Key name or key prefix if udid is specified
    /// - parameter uuid:                   Optional unique identifier
    /// - parameter kind:                   Type of value to store.
    ///
    /// - returns: A new `StoreKey` instance
    init(
        _ prefixOrName: String,
        uuid: String? = nil,
        kind: StoreKind = .userDefaults
    ) {
        let valueType = T.self
        let pieces = [kind.rawValue, prefixOrName, uuid, "\(type(of: valueType))"]

        name = pieces.compactMap { $0 }.joined(separator: "_")
        self.valueType = valueType
        self.uuid = uuid
        self.kind = kind
    }
}

/// Keys should add static `StoreKey` constants using extensions
public class StoreKeys {}
