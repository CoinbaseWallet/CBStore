// Copyright (c) 2017-2018 Coinbase Inc. See LICENSE

import RxSwift
@testable import Stores
import XCTest

let unitTestsTimeout: TimeInterval = 1

class StoresTests: XCTestCase {
    private let stores = Store()

    override func setUp() {
        super.setUp()
        stores.set(.stringBasedKey, value: nil)
        stores.set(.floatBasedKey, value: nil)
        stores.set(.dataKey, value: nil)

        stores.set(.keychainStringBasedKey, value: nil)
        stores.set(.keychainFloatBasedKey, value: nil)
        stores.set(.keychainDataKey, value: nil)
    }

    // MARK: - User Default tests

    func testUserDefaultsDataBasedKey() {
        let expectedData = "hello world".data(using: .utf8)!
        stores.set(.dataKey, value: expectedData)
        let actualData = stores.get(.dataKey)

        XCTAssertEqual(expectedData, actualData)
    }

    func testUserDefaultStringBasedKey() {
        let expected = "hello world"
        stores.set(.stringBasedKey, value: expected)
        let actual = stores.get(.stringBasedKey)

        XCTAssertEqual(expected, actual)
    }

    func testUserDefaultFloatBasedKey() {
        let expected: Float = 1234
        stores.set(.floatBasedKey, value: expected)
        let actual = stores.get(.floatBasedKey)

        XCTAssertEqual(expected, actual)
    }

    func testUserDefaultsSetsWithMultipleKey() {
        let expectedFloat: Float = 234_567
        let expectedString = "hello world"

        stores.set(.floatBasedKey, value: expectedFloat)
        stores.set(.stringBasedKey, value: expectedString)

        XCTAssertEqual(expectedFloat, stores.get(.floatBasedKey))
        XCTAssertEqual(expectedString, stores.get(.stringBasedKey))
    }

    // MARK: - Keychain tests

    func testKeychainDataBasedKey() {
        let expectedData = "hello world".data(using: .utf8)!
        stores.set(.keychainDataKey, value: expectedData)
        let actualData = stores.get(.keychainDataKey)

        XCTAssertEqual(expectedData, actualData)
    }

    func testKeychainStringBasedKey() {
        let expected = "hello world"
        stores.set(.keychainStringBasedKey, value: expected)
        let actual = stores.get(.keychainStringBasedKey)

        XCTAssertEqual(expected, actual)
    }

    func testKeychainFloatBasedKey() {
        let expected: Float = 4321
        stores.set(.keychainFloatBasedKey, value: expected)
        let actual = stores.get(.keychainFloatBasedKey)

        XCTAssertEqual(expected, actual)
    }

    func testKeychainSetsWithMultipleKey() {
        let expectedFloat: Float = 234_567
        let expectedString = "hello world"

        stores.set(.keychainFloatBasedKey, value: expectedFloat)
        stores.set(.keychainStringBasedKey, value: expectedString)

        XCTAssertEqual(expectedFloat, stores.get(.keychainFloatBasedKey))
        XCTAssertEqual(expectedString, stores.get(.keychainStringBasedKey))
    }

    func testMemoryDataBasedKey() {
        let expectedData = "hello world".data(using: .utf8)!
        stores.set(.memDataKey, value: expectedData)
        let actualData = stores.get(.memDataKey)

        XCTAssertEqual(expectedData, actualData)
    }

    func testMemoryStringBasedKey() {
        let expected = "hello world"
        stores.set(.memStringBasedKey, value: expected)
        let actual = stores.get(.memStringBasedKey)

        XCTAssertEqual(expected, actual)
    }

    func testMemoryFloatBasedKey() {
        let expected: Float = 4321
        stores.set(.memFloatBasedKey, value: expected)
        let actual = stores.get(.memFloatBasedKey)

        XCTAssertEqual(expected, actual)
    }

    func testMemorySetsWithMultipleKey() {
        let expectedFloat: Float = 234_567
        let expectedString = "hello world"

        stores.set(.memFloatBasedKey, value: expectedFloat)
        stores.set(.memStringBasedKey, value: expectedString)

        XCTAssertEqual(expectedFloat, stores.get(.memFloatBasedKey))
        XCTAssertEqual(expectedString, stores.get(.memStringBasedKey))
    }

    // MARK: - Test observers

    func testUserDefaultsObserver() {
        let expectation = self.expectation(description: "testUserDefaultsObserver")
        let disposeBag = DisposeBag()
        let expected = "Helllllllo"
        var actual = ""

        stores.observe(.stringBasedKey).subscribe(onNext: { value in
            actual = value ?? ""
            expectation.fulfill()
        }).disposed(by: disposeBag)

        stores.set(.stringBasedKey, value: expected)

        wait(for: [expectation], timeout: unitTestsTimeout)

        XCTAssertEqual(expected, actual)
    }

    func testKeychainObserver() {
        let expectation = self.expectation(description: "testKeychainObserver")
        let disposeBag = DisposeBag()
        let expected = "Hello Coinbase"
        var actual = ""

        stores.observe(.keychainStringBasedKey).subscribe(onNext: { value in
            actual = value ?? ""
            expectation.fulfill()
        }).disposed(by: disposeBag)

        stores.set(.keychainStringBasedKey, value: expected)

        wait(for: [expectation], timeout: unitTestsTimeout)

        XCTAssertEqual(expected, actual)
    }

    func testMemoryObserver() {
        let expectation = self.expectation(description: "testMemObserver")
        let disposeBag = DisposeBag()
        let expected = "Hello Coinbase"
        var actual = ""

        stores.observe(.memStringBasedKey).subscribe(onNext: { value in
            actual = value ?? ""
            expectation.fulfill()
        }).disposed(by: disposeBag)

        stores.set(.memStringBasedKey, value: expected)

        wait(for: [expectation], timeout: unitTestsTimeout)

        XCTAssertEqual(expected, actual)
    }
}

extension StoreKeys {
    // user defaults based
    static let stringBasedKey = StoreKey<String>("string_key", kind: .userDefaults)
    static let floatBasedKey = StoreKey<Float>("float_key", kind: .userDefaults)
    static let dataKey = StoreKey<Data>("data_key", kind: .userDefaults)

    // keychain based
    static let keychainStringBasedKey = StoreKey<String>("kstring_key", kind: .keychain)
    static let keychainFloatBasedKey = StoreKey<Float>("kfloat_key", kind: .keychain)
    static let keychainDataKey = StoreKey<Data>("kchain_data_key", kind: .keychain)

    // Memory based
    static let memStringBasedKey = StoreKey<String>("mem_string_key", kind: .memory)
    static let memFloatBasedKey = StoreKey<Float>("mem_float_key", kind: .memory)
    static let memDataKey = StoreKey<Data>("memdata_key", kind: .memory)

}

struct ExampleStruct: Storable, Codable, Equatable {
    let name: String
    let age: Int
}
