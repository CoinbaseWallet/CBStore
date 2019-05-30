// Copyright (c) 2017-2019 Coinbase Inc. See LICENSE

import Foundation

public enum KeychainAccessibleKind: String {
    /// The data in the keychain item can be accessed only while the device is unlocked by the user.
    case whenUnlocked

    /// The data in the keychain item cannot be accessed after a restart until the device has been unlocked once by
    /// the user.
    case afterFirstUnlock

    /// The data in the keychain item can always be accessed regardless of whether the device is locked.
    case always

    /// The data in the keychain can only be accessed when the device is unlocked. Only available if a passcode is
    /// set on the device.
    case whenPasscodeSetThisDeviceOnly

    /// The data in the keychain item can be accessed only while the device is unlocked by the user.
    case whenUnlockedThisDeviceOnly

    /// The data in the keychain item cannot be accessed after a restart until the device has been unlocked once by
    /// the user.
    case afterFirstUnlockThisDeviceOnly

    /// The data in the keychain item can always be accessed regardless of whether the device is locked.
    case alwaysThisDeviceOnly

    /// Get raw accessible kind value for keychain storage
    var asSecurityAttribute: CFString {
        switch self {
        case .whenUnlocked:
            return kSecAttrAccessibleWhenUnlocked
        case .afterFirstUnlock:
            return kSecAttrAccessibleAfterFirstUnlock
        case .always: return
            kSecAttrAccessibleAlways
        case .whenPasscodeSetThisDeviceOnly:
            return kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
        case .whenUnlockedThisDeviceOnly:
            return kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        case .afterFirstUnlockThisDeviceOnly:
            return kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        case .alwaysThisDeviceOnly:
            return kSecAttrAccessibleAlwaysThisDeviceOnly
        }
    }
}
