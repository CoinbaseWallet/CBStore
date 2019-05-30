// Copyright (c) 2017-2019 Coinbase Inc. See LICENSE

import Foundation

public class UserDefaultsStoreKey<T>: StoreKey<T> {
    /// Constructor to create a custom user defaults store key
    ///
    /// - parameter prefixOrName: Key name or key prefix if udid is specified
    /// - parameter uuid:         Optional unique identifier
    ///
    /// - returns: A new `StoreKey` instance
    public init(_ prefixOrName: String, uuid: String? = nil, syncNow: Bool = false) {
        super.init(prefixOrName, uuid: uuid, kind: .userDefaults, syncNow: syncNow)
    }
}
