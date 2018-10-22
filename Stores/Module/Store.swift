// Copyright (c) 2017-2018 Coinbase Inc. See LICENSE

import Foundation
import RxSwift

private let kValueKey = "StoresKeychainStorageKey"

/// Utility used to simplify interface to keychain or user defaults
public final class Store: StoreProtocol {
    private var changeObservers = [String: Any]()
    private let userDefaultStorage = UserDefaultsStorage()
    private let memoryStorage = MemoryStorage()

    public init() { }

    /// Set value for key
    ///
    /// - parameter key:   Key for store value
    /// - parameter value: Value to be stored
    public func set<T: Storable>(_ key: StoreKey<T>, value: T?) {
        let storage = self.storage(for: key)

        switch key.kind {
        case .keychain:
            if T.self == Data.self {
                storage.set(key.name, value: value?.toStoreValue())
            } else if let value = value {
                let dict = [kValueKey: value.toStoreValue() as AnyObject]
                let data = try? JSONSerialization.data(withJSONObject: dict, options: [])
                storage.set(key.name, value: data)
            } else {
                storage.set(key.name, value: nil)
            }
        case .userDefaults, .memory:
            storage.set(key.name, value: value?.toStoreValue())
        }

        observer(for: key).onNext(value)
    }

    /// Get value for key
    ///
    /// - parameter key: Key for store value
    ///
    /// - returns: Value if exists or nil
    public func get<T: Storable>(_ key: StoreKey<T>) -> T? {
        let storage = self.storage(for: key)

        switch key.kind {
        case .keychain:
            if T.self == Data.self {
                let storedValue = storage.get(key.name)
                return T.fromStoreValue(storedValue)
            } else if let data = storage.get(key.name) as? Data,
                let dict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] {
                let storedValue = dict?[kValueKey]
                return T.fromStoreValue(storedValue)
            } else {
                return nil
            }
        case .userDefaults, .memory:
            let storedValue = storage.get(key.name)
            return T.fromStoreValue(storedValue)
        }
    }

    /// Determine whether a value exists
    ///
    /// - parameter key: Key for store value
    ///
    /// - returns: True if value exists.
    public func has<T: Storable>(_ key: StoreKey<T>) -> Bool {
        let storedValue = storage(for: key).get(key.name)
        return T.fromStoreValue(storedValue) != nil
    }

    /// Add observer for store changes
    ///
    /// - parameter key: Key to start observing for changes
    ///
    /// - returns: Observer
    public func observe<T: Storable>(_ key: StoreKey<T>) -> Observable<T?> {
        return observer(for: key).asObservable()
    }

    // MARK: -

    private func observer<T: Storable>(for key: StoreKey<T>) -> PublishSubject<T?> {
        if let observer = self.changeObservers[key.name] as? PublishSubject<T?> {
            return observer
        } else {
            let observer = PublishSubject<T?>()
            changeObservers[key.name] = observer
            return observer
        }
    }

    private func storage<T: Storable>(for key: StoreKey<T>) -> Storage {
        switch key.kind {
        case .keychain:
            let group = Bundle.main.keychainGroupID
            if let accessible = (key as? KeychainStoreKey<T>)?.accessible {
                return KeychainStorage(group: group, accessible: accessible.asSecurityAttribute)
            } else {
                return KeychainStorage(group: group)
            }

        case .userDefaults:
            return userDefaultStorage
        case .memory:
            return memoryStorage
        }
    }
}
