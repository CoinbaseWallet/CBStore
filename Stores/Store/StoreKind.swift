// Copyright (c) 2017-2018 Coinbase Inc. See LICENSE

import Foundation

/// Represents the kind of store.
public enum StoreKind: String {
    /// Store data to Keychain.
    case keychain

    /// Stores data to UserDefaults.
    case userDefaults

    /// Store data to memory.
    case memory
}
