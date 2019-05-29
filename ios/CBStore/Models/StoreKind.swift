// Copyright (c) 2017-2019 Coinbase Inc. See LICENSE

import Foundation

/// Represents the kind of store.
public enum StoreKind: String, CaseIterable {
    /// Store data to Keychain.
    case keychain

    /// Stores data to UserDefaults.
    case userDefaults

    /// Store data to memory.
    case memory

    /// Store data to iCloud
    case cloud
}
