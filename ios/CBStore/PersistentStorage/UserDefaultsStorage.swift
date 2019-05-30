// Copyright (c) 2017-2019 Coinbase Inc. See LICENSE

import Foundation

/// Storage for user defaults
struct UserDefaultsStorage: Storage {
    func set(_ key: String, value: Any?) {
        if let value = value {
            return UserDefaults.standard.set(value, forKey: key)
        } else if value == nil {
            return UserDefaults.standard.removeObject(forKey: key)
        }
    }

    func get(_ key: String) -> Any? {
        return UserDefaults.standard.object(forKey: key)
    }

    func destroy() {
        if let domain = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: domain)
        }
    }

    func sync() {
        CFPreferencesAppSynchronize(kCFPreferencesCurrentApplication)
    }
}
