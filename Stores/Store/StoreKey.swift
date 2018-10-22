// Copyright (c) 2017-2018 Coinbase Inc. See LICENSE

import Foundation

public final class StoreKey<T>: StoreKeys {
    /// Type of store. i.e. keychain vs user defaults vs cloud KeyValue store
    public let kind: StoreKind

    /// Store key name
    public let name: String

    /// Optional unique identifier for key. Typically used to target a specific key with unique id
    public let uuid: String?

    /// Stored value type
    let valueType: T.Type

    /// Keychain `kSecAttrAccessible` value. Ignored for UserDefaults
    let keychainAccessibleKind: CFString

    /// Constructor to create a custom store key
    ///
    /// - parameter prefixOrName:           Key name or key prefix if udid is specified
    /// - parameter uuid:                   Optional unique identifier
    /// - parameter kind:                   Type of value to store.
    /// - parameter keychainAccessibleKind: Sets the keychain accessible kind. This is ignored for user defaults
    ///
    /// - returns: A new `StoreKey` instance
    public init(
        _ prefixOrName: String,
        uuid: String? = nil,
        kind: StoreKind = .userDefaults,
        keychainAccessibleKind: CFString = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
    ) {
        let valueType = T.self
        let pieces = [kind.rawValue, prefixOrName, uuid, "\(type(of: valueType))"]

        name = pieces.compactMap { $0 }.joined(separator: "_")
        self.valueType = valueType
        self.uuid = uuid
        self.kind = kind
        self.keychainAccessibleKind = keychainAccessibleKind
    }
}

/// Keys should add static `StoreKey` constants using extensions
public class StoreKeys {}
