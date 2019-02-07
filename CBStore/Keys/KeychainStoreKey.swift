// Copyright (c) 2017-2019 Coinbase Inc. See LICENSE

import Foundation

public class KeychainStoreKey<T>: StoreKey<T> {
    /// Keychain `kSecAttrAccessible` value. Ignored for UserDefaults
    let accessible: KeychainAccessibleKind

    /// Constructor to create a custom keychain store key
    ///
    /// - parameter prefixOrName: Key name or key prefix if udid is specified
    /// - parameter uuid:         Optional unique identifier
    /// - parameter accessible:   Sets the keychain accessible kind. This is ignored for user defaults
    ///
    /// - returns: A new `StoreKey` instance
    public init(
        _ prefixOrName: String,
        uuid: String? = nil,
        accessible: KeychainAccessibleKind = .whenUnlockedThisDeviceOnly
    ) {
        self.accessible = accessible
        super.init(prefixOrName, uuid: uuid, kind: .keychain)
    }
}
