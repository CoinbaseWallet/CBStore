// Copyright (c) 2017-2019 Coinbase Inc. See LICENSE

import CBStore
import RxBlocking
import RxSwift
import XCTest

let unitTestsTimeout: TimeInterval = 1

class StoreTests: XCTestCase {
    private let stores = Store()

    override func setUp() {
        super.setUp()

        stores.removeAll(kinds: [.cloud, .keychain, .memory, .userDefaults])
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

    func testUserDefaultCodableKey() {
        let obj = ExampleStruct(name: "testName", age: 123)
        stores.set(.codableKey, value: obj)

        XCTAssertEqual(obj, stores.get(.codableKey))
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

    func testCloudCodableKey() {
        let obj = ExampleStruct(name: "testName", age: 123)
        stores.set(.cloudCodableKey, value: obj)

        XCTAssertEqual(obj, stores.get(.cloudCodableKey))
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

    func testKeychainCodableKey() {
        let obj = ExampleStruct(name: "testName", age: 123)
        stores.set(.keychainCodableKey, value: obj)

        XCTAssertEqual(obj, stores.get(.keychainCodableKey))
    }

    // MARK: - Memory store tests

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

    func testMemoryCodableKey() {
        let obj = ExampleStruct(name: "testName", age: 123)
        stores.set(.memCodableKey, value: obj)

        XCTAssertEqual(obj, stores.get(.memCodableKey))
    }

    func testDestroy() throws {
        let kvStore = Store()
        let expected: Float = 4321

        XCTAssertFalse(kvStore.has(.memFloatBasedKey))
        XCTAssertFalse(kvStore.has(.keychainFloatBasedKey))
        XCTAssertFalse(kvStore.has(.floatBasedKey))
        XCTAssertFalse(kvStore.has(.cloudFloatBasedKey))

        kvStore.set(.memFloatBasedKey, value: expected)
        kvStore.set(.keychainFloatBasedKey, value: expected)
        kvStore.set(.floatBasedKey, value: expected)
        kvStore.set(.cloudFloatBasedKey, value: expected)

        XCTAssertTrue(kvStore.has(.memFloatBasedKey))
        XCTAssertTrue(kvStore.has(.keychainFloatBasedKey))
        XCTAssertTrue(kvStore.has(.floatBasedKey))
        XCTAssertTrue(kvStore.has(.cloudFloatBasedKey))

        let memFloatValue = try kvStore.observe(.memFloatBasedKey).toBlocking(timeout: unitTestsTimeout).first()
        let kChainFloatValue = try kvStore.observe(.keychainFloatBasedKey).toBlocking(timeout: unitTestsTimeout).first()
        let floatValue = try kvStore.observe(.floatBasedKey).toBlocking(timeout: unitTestsTimeout).first()
        let cloudFloatValue = try kvStore.observe(.cloudFloatBasedKey).toBlocking(timeout: unitTestsTimeout).first()

        XCTAssertEqual(expected, memFloatValue)
        XCTAssertEqual(expected, kChainFloatValue)
        XCTAssertEqual(expected, floatValue)
        XCTAssertEqual(expected, cloudFloatValue)

        kvStore.destroy()

        XCTAssertFalse(kvStore.has(.memFloatBasedKey))
        XCTAssertFalse(kvStore.has(.keychainFloatBasedKey))
        XCTAssertFalse(kvStore.has(.floatBasedKey))
        XCTAssertFalse(kvStore.has(.cloudFloatBasedKey))

        do {
            _ = try kvStore.observe(.memFloatBasedKey).toBlocking(timeout: unitTestsTimeout).first()
            XCTFail("Should've thrown an exception")
        } catch {
            XCTAssertTrue((error as? StoreError) == StoreError.storeDestroyed)
        }

        do {
            _ = try kvStore.observe(.keychainFloatBasedKey).toBlocking(timeout: unitTestsTimeout).first()
            XCTFail("Should've thrown an exception")
        } catch {
            XCTAssertTrue((error as? StoreError) == StoreError.storeDestroyed)
        }

        do {
            _ = try kvStore.observe(.floatBasedKey).toBlocking(timeout: unitTestsTimeout).first()
            XCTFail("Should've thrown an exception")
        } catch {
            XCTAssertTrue((error as? StoreError) == StoreError.storeDestroyed)
        }

        do {
            _ = try kvStore.observe(.cloudFloatBasedKey).toBlocking(timeout: unitTestsTimeout).first()
            XCTFail("Should've thrown an exception")
        } catch {
            XCTAssertTrue((error as? StoreError) == StoreError.storeDestroyed)
        }

        XCTAssertTrue(kvStore.isDestroyed)
    }
    
    
    func testRemoveAll() throws {
        let kvStore = Store()
        let expected: Float = 4321
        
        XCTAssertFalse(kvStore.has(.memFloatBasedKey))
        XCTAssertFalse(kvStore.has(.keychainFloatBasedKey))
        XCTAssertFalse(kvStore.has(.floatBasedKey))
        XCTAssertFalse(kvStore.has(.cloudFloatBasedKey))
        
        kvStore.set(.memFloatBasedKey, value: expected)
        kvStore.set(.keychainFloatBasedKey, value: expected)
        kvStore.set(.floatBasedKey, value: expected)
        kvStore.set(.cloudFloatBasedKey, value: expected)
        
        XCTAssertTrue(kvStore.has(.memFloatBasedKey))
        XCTAssertTrue(kvStore.has(.keychainFloatBasedKey))
        XCTAssertTrue(kvStore.has(.floatBasedKey))
        XCTAssertTrue(kvStore.has(.cloudFloatBasedKey))
        
        let memFloatValue = try kvStore.observe(.memFloatBasedKey).toBlocking(timeout: unitTestsTimeout).first()
        let kChainFloatValue = try kvStore.observe(.keychainFloatBasedKey).toBlocking(timeout: unitTestsTimeout).first()
        let floatValue = try kvStore.observe(.floatBasedKey).toBlocking(timeout: unitTestsTimeout).first()
        let cloudFloatValue = try kvStore.observe(.cloudFloatBasedKey).toBlocking(timeout: unitTestsTimeout).first()
        
        XCTAssertEqual(expected, memFloatValue)
        XCTAssertEqual(expected, kChainFloatValue)
        XCTAssertEqual(expected, floatValue)
        XCTAssertEqual(expected, cloudFloatValue)
        
        kvStore.removeAll(kinds: [.cloud, .keychain, .memory, .userDefaults])
        
        XCTAssertFalse(kvStore.has(.memFloatBasedKey))
        XCTAssertFalse(kvStore.has(.keychainFloatBasedKey))
        XCTAssertFalse(kvStore.has(.floatBasedKey))
        XCTAssertFalse(kvStore.has(.cloudFloatBasedKey))

        let memFloatValue2 = try kvStore.observe(.memFloatBasedKey).toBlocking(timeout: unitTestsTimeout).first() ?? nil
        let kChainFloatValue2 = try kvStore.observe(.keychainFloatBasedKey).toBlocking(timeout: unitTestsTimeout).first() ?? nil
        let floatValue2 = try kvStore.observe(.floatBasedKey).toBlocking(timeout: unitTestsTimeout).first() ?? nil
        let cloudFloatValue2 = try kvStore.observe(.cloudFloatBasedKey).toBlocking(timeout: unitTestsTimeout).first() ?? nil
        
        XCTAssertNil(memFloatValue2)
        XCTAssertNil(kChainFloatValue2)
        XCTAssertNil(floatValue2)
        XCTAssertNil(cloudFloatValue2)
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
    static let codableKey = UserDefaultsStoreKey<ExampleStruct>("codable_key")

    // cloud based
    static let cloudStringBasedKey = CloudStoreKey<String>("cloud_string_key")
    static let cloudFloatBasedKey = CloudStoreKey<Float>("cloud_float_key")
    static let cloudDataBasedKey = CloudStoreKey<Data>("cloud_data_key")
    static let cloudCodableKey = CloudStoreKey<ExampleStruct>("cloud_codable_key")

    // keychain based
    static let keychainStringBasedKey = KeychainStoreKey<String>("kstring_key")
    static let keychainFloatBasedKey = KeychainStoreKey<Float>("kfloat_key")
    static let keychainDataKey = KeychainStoreKey<Data>("kchain_data_key")
    static let keychainCodableKey = KeychainStoreKey<ExampleStruct>("keychain_codable_key")

    // Memory based
    static let memStringBasedKey = MemoryStoreKey<String>("mem_string_key")
    static let memFloatBasedKey = MemoryStoreKey<Float>("mem_float_key")
    static let memDataKey = MemoryStoreKey<Data>("memdata_key")
    static let memCodableKey = MemoryStoreKey<ExampleStruct>("mem_codable_key")
}

struct ExampleStruct: Storable, Codable, Equatable {
    let name: String
    let age: Int
}
