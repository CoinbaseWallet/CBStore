// Copyright (c) 2017-2019 Coinbase Inc. See LICENSE

import Foundation
import RxSwift

private let kValueKey = "StoresKeychainStorageKey"
private typealias ChangeObserver = (subject: Any, clearClosure: () -> Void)

/// Utility used to simplify interface to keychain or user defaults
public final class Store: StoreProtocol {
    private var changeObservers = [String: ChangeObserver]()
    private let userDefaultStorage = UserDefaultsStorage()
    private let memoryStorage = MemoryStorage()
    private let cloudStorage = CloudStorage()
    private let accessQueue = DispatchQueue(
        label: "CBStore.Store.accessQueue",
        qos: .userInitiated,
        attributes: .concurrent
    )

    private let changeObserverAccessQueue = DispatchQueue(
        label: "CBStore.Store.changeObserverAccessQueue",
        qos: .userInitiated,
        attributes: .concurrent
    )

    /// Determine whether the store is destroyed
    public private(set) var isDestroyed: Bool = false

    public init() {}

    /// Set value for key
    ///
    /// - parameter key:   Key for store value
    /// - parameter value: Value to be stored
    public func set<T: Storable>(_ key: StoreKey<T>, value: T?) {
        var hasObserver = false

        accessQueue.sync {
            hasObserver = self.hasObserver(for: key.name)

            if self.isDestroyed {
                return
            }

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

            if key.syncNow {
                storage.sync()
            }
        }

        if hasObserver, isDestroyed {
            observer(for: key).onError(StoreError.storeDestroyed)
        } else if !isDestroyed {
            observer(for: key).onNext(value)
        }
    }

    /// Get value for key
    ///
    /// - parameter key: Key for store value
    ///
    /// - returns: Value if exists or nil
    public func get<T: Storable>(_ key: StoreKey<T>) -> T? {
        var value: T?

        accessQueue.sync {
            if self.isDestroyed {
                value = nil
                return
            }

            let storage = self.storage(for: key)

            switch key.kind {
            case .keychain:
                if T.self == Data.self {
                    let storedValue = storage.get(key.name)

                    value = T.fromStoreValue(storedValue)
                } else if let data = storage.get(key.name) as? Data,
                    let dict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] {
                    let storedValue = dict?[kValueKey]

                    value = T.fromStoreValue(storedValue)
                } else {
                    value = nil
                }
            case .userDefaults, .memory:
                let storedValue = storage.get(key.name)

                value = T.fromStoreValue(storedValue)
            case .cloud:
                let storedValue = storage.get(key.name)

                value = T.fromStoreValue(storedValue)
            }
        }

        return value
    }

    /// Determine whether a value exists
    ///
    /// - parameter key: Key for store value
    ///
    /// - returns: True if value exists.
    public func has<T: Storable>(_ key: StoreKey<T>) -> Bool {
        var hasValue: Bool = false

        accessQueue.sync {
            if self.isDestroyed {
                hasValue = false
            } else {
                hasValue = get(key) != nil
            }
        }

        return hasValue
    }

    /// Add observer for store changes
    ///
    /// - parameter key: Key to start observing for changes
    ///
    /// - returns: Observer
    public func observe<T: Storable>(_ key: StoreKey<T>) -> Observable<T?> {
        var observable: Observable<T?>!

        accessQueue.sync {
            if self.isDestroyed {
                observable = .error(StoreError.storeDestroyed)
            } else {
                observable = observer(for: key).asObservable()
            }
        }

        return observable
    }

    /// Destroy the store. This will make the current store unusable
    public func destroy() {
        accessQueue.sync(flags: .barrier) {
            if self.isDestroyed {
                return
            }

            self.isDestroyed = true
            self.deleteAllEntries(kinds: StoreKind.allCases)
        }
    }

    /// Delete all entries for given store kinds
    ///
    /// - parameter kinds: Array of `StoreKind` to clear out
    public func removeAll(kinds: [StoreKind]) {
        accessQueue.sync {
            if self.isDestroyed {
                return
            }

            self.deleteAllEntries(kinds: kinds)
        }

        changeObservers.values.forEach { $0.clearClosure() }
    }

    // MARK: -

    private func deleteAllEntries(kinds: [StoreKind]) {
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

    private func observer<T: Storable>(for key: StoreKey<T>) -> BehaviorSubject<T?> {
        // Check if we have an observer registered in concurrent mode
        var currentObserver: BehaviorSubject<T?>?
        changeObserverAccessQueue.sync {
            currentObserver = self.changeObservers[key.name]?.subject as? BehaviorSubject<T?>
        }

        if let observer = currentObserver {
            return observer
        }

        // If we can't find an observer, enter serial mode and check or create new observer
        var newObserver: BehaviorSubject<T?>!
        let value = get(key)

        changeObserverAccessQueue.sync(flags: .barrier) {
            if let observer = self.changeObservers[key.name]?.subject as? BehaviorSubject<T?> {
                newObserver = observer
                return
            }

            let observer = BehaviorSubject<T?>(value: value)
            changeObservers[key.name] = (subject: observer, clearClosure: { observer.onNext(nil) })
            newObserver = observer
        }

        return newObserver
    }

    private func hasObserver(for keyName: String) -> Bool {
        var hasObserver = false

        changeObserverAccessQueue.sync {
            hasObserver = self.changeObservers[keyName] != nil
        }

        return hasObserver
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
