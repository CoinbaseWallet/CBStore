// Copyright (c) 2017-2018 Coinbase Inc. See LICENSE

import Foundation
import RxSwift

private let kValueKey = "StoresKeychainStorageKey"

/// Utility used to simplify interface to keychain or user defaults
public final class Store: StoreProtocol {
    private var changeObservers = [String: Any]()
    private let userDefaultStorage = UserDefaultsStorage()
    private let memoryStorage = MemoryStorage()
    private let cloudStorage = CloudStorage()

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
        case .cloud:
            cloudStorage.set(key.name, value: value?.toStoreValue())
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
        case .cloud:
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
        return get(key) != nil
    }

    /// Add observer for store changes
    ///
    /// - parameter key: Key to start observing for changes
    ///
    /// - returns: Observer
    public func observe<T: Storable>(_ key: StoreKey<T>) -> Observable<T?> {
        return observer(for: key).asObservable()
    }

    /// Delete all entries for given store kinds
    ///
    /// - parameter kinds: Array of `StoreKind` to clear out
    public func destroy(kinds: [StoreKind]) {
        kinds.forEach { kind in
            switch kind {
            case .keychain:
                let group = Bundle.main.keychainGroupID
                
                KeychainStorage(group: group).destroy()

            case .userDefaults:
                userDefaultStorage.destroy()
            case .memory:
                memoryStorage.destroy()
            case .cloud:
                cloudStorage.destroy()
            }
        }
    }

    // MARK: -

    private func observer<T: Storable>(for key: StoreKey<T>) -> BehaviorSubject<T?> {
        if let observer = self.changeObservers[key.name] as? BehaviorSubject<T?> {
            return observer
        } else {
            let value = get(key)
            let observer = BehaviorSubject<T?>(value: value)
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
        case .cloud:
            return cloudStorage
        }
    }
}
