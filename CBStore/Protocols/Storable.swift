// Copyright (c) 2017-2018 Coinbase Inc. See LICENSE

import Foundation
import CoreGraphics

/// This protocol should be used to declare data types that can be stored in keychain or user defaults.
public protocol Storable {
    /// Convert storable to a format storage layer can use
    func toStoreValue() -> Any?

    /// Converts stored value to a storable instance
    static func fromStoreValue(_ value: Any?) -> Self?
}

/// Default Storable implementation
public extension Storable {
    func toStoreValue() -> Any? {
        return self
    }

    public static func fromStoreValue(_ value: Any?) -> Self? {
        return value as? Self
    }
}

extension RawRepresentable where Self: Storable {
    func toStoreValue() -> Any? {
        return self.rawValue
    }

    public static func fromStoreValue(_ value: Any?) -> Self? {
        guard let value = value as? RawValue else { return nil }

        return self.init(rawValue: value)
    }
}

extension String: Storable {}
extension Int: Storable {}
extension Int32: Storable {}
extension UInt32: Storable {}
extension Double: Storable {}
extension Float: Storable {}
extension CGFloat: Storable {}
extension Bool: Storable {}
extension Date: Storable {}
extension Data: Storable {}
extension Dictionary: Storable {}
extension Array: Storable {}
