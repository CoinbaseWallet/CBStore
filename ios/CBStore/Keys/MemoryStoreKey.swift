// Copyright (c) 2017-2019 Coinbase Inc. See LICENSE

import Foundation

public class MemoryStoreKey<T>: StoreKey<T> {
    /// Constructor to create a custom memory store key
    ///
    /// - parameter prefixOrName: Key name or key prefix if udid is specified
    /// - parameter uuid:         Optional unique identifier
    ///
    /// - returns: A new `StoreKey` instance
    public init(_ prefixOrName: String, uuid: String? = nil) {
        super.init(prefixOrName, uuid: uuid, kind: .memory)
    }
}
