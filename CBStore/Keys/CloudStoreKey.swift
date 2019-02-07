// Copyright (c) 2017-2019 Coinbase Inc. See LICENSE

import Foundation

public class CloudStoreKey<T>: StoreKey<T> {
    /// Constructor to create a custom cloud store key
    ///
    /// - Parameters:
    ///   - prefixOrName: Key name or key prefix if uuid is specified
    ///   - uuid: Optional unique identifier
    ///
    /// - Returns: A new `StoreKey` instance
    public init(_ prefixOrName: String, uuid: String? = nil) {
        super.init(prefixOrName, uuid: uuid, kind: .cloud)
    }
}
