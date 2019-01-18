// Copyright (c) 2017-2018 Coinbase Inc. See LICENSE

import RxSwift
import CBStore
import XCTest

let unitTestsTimeout: TimeInterval = 1

class StoresTests: XCTestCase {
    private let stores = Store()

    override func setUp() {
        super.setUp()

        stores.destroy(kinds: [.cloud, .keychain, .memory, .userDefaults])
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

    // MARK: - Cloud tests

    func testCloudDataBasedKey() {
        let expectedData = "hello world".data(using: .utf8)!
        stores.set(.cloudDataBasedKey, value: expectedData)
        let actualData = stores.get(.cloudDataBasedKey)

        XCTAssertEqual(expectedData, actualData)
    }

    func testCloudStringBasedKey() {
        let expected = "hello world"
        stores.set(.cloudStringBasedKey, value: expected)
        let actual = stores.get(.cloudStringBasedKey)

        XCTAssertEqual(expected, actual)
    }

    func testCloudFloatBasedKey() {
        let expected: Float = 1234
        stores.set(.cloudFloatBasedKey, value: expected)
        let actual = stores.get(.cloudFloatBasedKey)

        XCTAssertEqual(expected, actual)
    }

    func testCloudSetsWithMultipleKey() {
        let expectedFloat: Float = 234_567
        let expectedString = "hello world"

        stores.set(.cloudFloatBasedKey, value: expectedFloat)
        stores.set(.cloudStringBasedKey, value: expectedString)

        XCTAssertEqual(expectedFloat, stores.get(.cloudFloatBasedKey))
        XCTAssertEqual(expectedString, stores.get(.cloudStringBasedKey))
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

    func testDestroy() {
        let expected: Float = 4321

        XCTAssertFalse(stores.has(.memFloatBasedKey))
        XCTAssertFalse(stores.has(.keychainFloatBasedKey))
        XCTAssertFalse(stores.has(.floatBasedKey))
        XCTAssertFalse(stores.has(.cloudFloatBasedKey))

        stores.set(.memFloatBasedKey, value: expected)
        stores.set(.keychainFloatBasedKey, value: expected)
        stores.set(.floatBasedKey, value: expected)
        stores.set(.cloudFloatBasedKey, value: expected)

        XCTAssertTrue(stores.has(.memFloatBasedKey))
        XCTAssertTrue(stores.has(.keychainFloatBasedKey))
        XCTAssertTrue(stores.has(.floatBasedKey))
        XCTAssertTrue(stores.has(.cloudFloatBasedKey))

        stores.destroy(kinds: [.cloud, .keychain, .memory, .userDefaults])

        XCTAssertFalse(stores.has(.memFloatBasedKey))
        XCTAssertFalse(stores.has(.keychainFloatBasedKey))
        XCTAssertFalse(stores.has(.floatBasedKey))
        XCTAssertFalse(stores.has(.cloudFloatBasedKey))
    }

    // MARK: - Test observers

    func testUserDefaultsObserverForInitialValue() {
        let expectation = self.expectation(description: "testUserDefaultsObserverForInitialValue")
        let disposeBag = DisposeBag()
        let expected = ""
        var actual = "whatever"

        stores.observe(.stringBasedKey).subscribe(onNext: { value in
            actual = value ?? ""
            expectation.fulfill()
        }).disposed(by: disposeBag)

        wait(for: [expectation], timeout: unitTestsTimeout)

        XCTAssertEqual(expected, actual)
    }

    func testUserDefaultsObserver() {
        let expectation = self.expectation(description: "testUserDefaultsObserver")
        let disposeBag = DisposeBag()
        let expected = "Helllllllo"
        var actual = ""

        stores.observe(.stringBasedKey).skip(1).subscribe(onNext: { value in
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

        stores.observe(.keychainStringBasedKey).skip(1).subscribe(onNext: { value in
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

        stores.observe(.memStringBasedKey).skip(1).subscribe(onNext: { value in
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
    static let stringBasedKey = UserDefaultsStoreKey<String>("string_key")
    static let floatBasedKey = UserDefaultsStoreKey<Float>("float_key")
    static let dataKey = UserDefaultsStoreKey<Data>("data_key")

    // cloud based
    static let cloudStringBasedKey = CloudStoreKey<String>("cloud_string_key")
    static let cloudFloatBasedKey = CloudStoreKey<Float>("cloud_float_key")
    static let cloudDataBasedKey = CloudStoreKey<Data>("cloud_data_key")

    // keychain based
    static let keychainStringBasedKey = KeychainStoreKey<String>("kstring_key")
    static let keychainFloatBasedKey = KeychainStoreKey<Float>("kfloat_key")
    static let keychainDataKey = KeychainStoreKey<Data>("kchain_data_key")

    // Memory based
    static let memStringBasedKey = MemoryStoreKey<String>("mem_string_key")
    static let memFloatBasedKey = MemoryStoreKey<Float>("mem_float_key")
    static let memDataKey = MemoryStoreKey<Data>("memdata_key")
}

struct ExampleStruct: Storable, Codable, Equatable {
    let name: String
    let age: Int
}
