// Copyright (c) 2017-2019 Coinbase Inc. See LICENSE

import Foundation

/// The entitlement can be added by navigating to Target > Capabilities > Keychain Sharing
private let kMissingEntitlement: Int32 = -34018
private let kAccountName = "coinbase-wallet"

/// Storage for keychain
struct KeychainStorage: Storage {
    private let isSynchronizable: Bool
    private let group: String
    private let accessible: CFString

    init(
        group: String,
        isSynchronizable: Bool = false,
        accessible: CFString = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
    ) {
        self.group = group
        self.isSynchronizable = isSynchronizable
        self.accessible = accessible
    }

    func set(_ key: String, value: Any?) {
        var query = queryDictionary(key: key)

        SecItemDelete(query as CFDictionary)

        if let value = value {
            query[kSecValueData as String] = value as AnyObject
            let status = SecItemAdd(query as CFDictionary, nil)

            assert(status != kMissingEntitlement, "Missing entitlement config")
            assert(status == errSecSuccess, "Unable to save \(key) to keychain")
        }
    }

    func get(_ key: String) -> Any? {
        var query = queryDictionary(key: key)
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnData as String] = kCFBooleanTrue

        var value: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &value)

        assert(status != kMissingEntitlement, "Missing entitlment config")

        return value
    }

    func destroy() {
        SecItemDelete([kSecClass as String: kSecClassGenericPassword] as CFDictionary)
    }

    func sync() {}

    // MARK: - Private helpers

    private func queryDictionary(key: String) -> [String: AnyObject] {
        var queryDictionary = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: kAccountName as AnyObject,
            kSecAttrAccessible as String: accessible as AnyObject,
            kSecAttrService as String: key as AnyObject,
        ]

        let shouldSync = isSynchronizable ? kCFBooleanTrue : kCFBooleanFalse
        queryDictionary[kSecAttrSynchronizable as String] = shouldSync as AnyObject

        #if !SIMULATOR
            queryDictionary[kSecAttrAccessGroup as String] = group as AnyObject?
        #endif

        return queryDictionary
    }
}
