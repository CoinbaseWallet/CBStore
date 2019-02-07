// Copyright (c) 2017-2019 Coinbase Inc. See LICENSE

import RxSwift

/// Store operation protocol. Generally used to stub out Stores in unit tests
public protocol StoreProtocol {
    /// Set value for key
    ///
    /// - parameter key:   Key for store value
    /// - parameter value: Value to be stored
    func set<T: Storable>(_ key: StoreKey<T>, value: T?)

    /// Get value for key
    ///
    /// - parameter key: Key for store value
    ///
    /// - returns: Value if exists or nil
    func get<T>(_ key: StoreKey<T>) -> T? where T: Storable

    /// Determine whether a value exists
    ///
    /// - parameter key: Key for store value
    ///
    /// - returns: True if value exists.
    func has<T>(_ key: StoreKey<T>) -> Bool where T: Storable

    /// Add observer for store changes
    ///
    /// - parameter key: Key to start observing for changes
    ///
    /// - returns: Observer
    func observe<T>(_ key: StoreKey<T>) -> Observable<T?> where T: Storable

    /// Destroy the store. This will make the current store unusable
    func destroy()

    /// Delete all entries for given store kinds
    ///
    /// - parameter kinds: Array of `StoreKind` to clear out
    func removeAll(kinds: [StoreKind])
}
