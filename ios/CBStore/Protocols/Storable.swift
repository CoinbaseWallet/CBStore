// Copyright (c) 2017-2019 Coinbase Inc. See LICENSE

import CoreGraphics
import Foundation

/// This protocol should be used to declare data types that can be stored in keychain or user defaults.
public protocol Storable {
    /// Convert storable to a format storage layer can use
    func toStoreValue() -> Any?

    /// Converts stored value to a storable instance
    static func fromStoreValue(_ value: Any?) -> Self?
}

/// This protocol should be implemented by structs/classes that want to use the default Storable implementation
public protocol DefaultStorable: Storable {}

/// Default Storable implementation for IdentityStorable structs and classes
public extension DefaultStorable {
    func toStoreValue() -> Any? {
        return self
    }

    static func fromStoreValue(_ value: Any?) -> Self? {
        return value as? Self
    }
}

extension String: DefaultStorable {}
extension Int: DefaultStorable {}
extension Int32: DefaultStorable {}
extension Int64: DefaultStorable {}
extension UInt: Storable {}
extension UInt32: DefaultStorable {}
extension UInt64: DefaultStorable {}
extension Double: DefaultStorable {}
extension Float: DefaultStorable {}
extension CGFloat: DefaultStorable {}
extension Bool: DefaultStorable {}
extension Date: DefaultStorable {}
extension Data: DefaultStorable {}
extension Dictionary: DefaultStorable {}
extension Array: DefaultStorable {}

/// Default Storable implementation for Codable structs/classes
public extension Storable where Self: Codable {
    func toStoreValue() -> Any? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .millisecondsSince1970
        encoder.dataEncodingStrategy = .base64
        return try? encoder.encode(self).base64EncodedString()
    }

    static func fromStoreValue(_ value: Any?) -> Self? {
        let decoder = JSONDecoder()
        decoder.dataDecodingStrategy = .base64
        decoder.dateDecodingStrategy = .millisecondsSince1970

        guard let base64String = value as? String, let data = Data(base64Encoded: base64String) else {
            return nil
        }

        return try? decoder.decode(self, from: data)
    }
}
