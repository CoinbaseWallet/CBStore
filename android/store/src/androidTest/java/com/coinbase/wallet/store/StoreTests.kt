package com.coinbase.wallet.store

import android.content.Context
import androidx.test.core.app.ApplicationProvider
import androidx.test.ext.junit.runners.AndroidJUnit4
import com.coinbase.wallet.core.util.toOptional
import com.coinbase.wallet.store.exceptions.StoreException
import com.coinbase.wallet.store.models.EncryptedSharedPrefsStoreKey
import com.coinbase.wallet.store.models.MemoryStoreKey
import com.coinbase.wallet.store.models.SharedPrefsStoreKey
import com.coinbase.wallet.store.models.StoreKind
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import org.junit.Assert
import org.junit.Assert.assertArrayEquals
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotEquals
import org.junit.Assert.assertNull
import org.junit.Test
import org.junit.runner.RunWith
import java.math.BigDecimal
import java.math.BigInteger
import java.net.URL
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit

@RunWith(AndroidJUnit4::class)
class StoreTests {
    @Test
    fun testStore() {
        val appContext = ApplicationProvider.getApplicationContext<Context>()
        val store = Store(appContext)
        val stringKey = SharedPrefsStoreKey(id = "string_key", uuid = "id", clazz = String::class.java)
        val boolKey = SharedPrefsStoreKey(id = "bool_key", uuid = "id", clazz = Boolean::class.java)
        val complexObjectKey = SharedPrefsStoreKey(id = "complex_object", clazz = MockComplexObject::class.java)
        val intKey = SharedPrefsStoreKey(id = "intKey", clazz = Int::class.java)
        val floatKey = SharedPrefsStoreKey(id = "floatKey", clazz = Float::class.java)
        val longKey = SharedPrefsStoreKey(id = "longKey", clazz = Long::class.java)
        val expected = "Hello Android CBStore"
        val expectedComplex = MockComplexObject(name = "hish", age = 37, wallets = listOf("hello", "world"))
        val expectedInt = 12345
        val expectedFloat = 1420f
        val expectedLong = 650022L

        store.set(intKey, expectedInt)
        store.set(floatKey, expectedFloat)
        store.set(longKey, expectedLong)
        store.set(stringKey, expected)
        store.set(boolKey, false)
        store.set(complexObjectKey, expectedComplex)
        store.set(TestKeys.computedKey(uuid = "random"), "hello")
        store.set(TestKeys.activeUser, "random")

        assertEquals(expectedInt, store.get(intKey))
        assertEquals(expectedFloat, store.get(floatKey))
        assertEquals(expectedLong, store.get(longKey))
        assertEquals(expected, store.get(stringKey))
        assertEquals(false, store.get(boolKey))
        assertEquals(expectedComplex, store.get(complexObjectKey))
        assertEquals("hello", store.get(TestKeys.computedKey(uuid = "random")))
    }

    @Test
    fun testMemory() {
        val expectedString = "Memory string goes here"
        val expectedBoolean = true
        val expectedInt = 8
        val appContext = ApplicationProvider.getApplicationContext<Context>()
        val store = Store(appContext)

        store.set(TestKeys.memoryString, expectedString)
        assertEquals(expectedString, store.get(TestKeys.memoryString))

        store.set(TestKeys.memoryBoolean, expectedBoolean)
        assertEquals(expectedBoolean, store.get(TestKeys.memoryBoolean))

        store.set(TestKeys.memoryInt, expectedInt)
        assertEquals(expectedInt, store.get(TestKeys.memoryInt))
    }

    @Test
    fun testObserver() {
        val expected = "Testing observer"
        val appContext = ApplicationProvider.getApplicationContext<Context>()
        val store = Store(appContext)
        val latchDown = CountDownLatch(1)
        var actual = ""

        GlobalScope.launch {
            store.observe(TestKeys.memoryString)
                .filter { it.value != null }
                .timeout(6, TimeUnit.SECONDS)
                .subscribe({ (element) ->
                    actual = element ?: throw AssertionError("No element found")
                    latchDown.countDown()
                }, { latchDown.countDown() })
        }

        store.set(TestKeys.memoryString, expected)
        latchDown.await()

        assertEquals(expected, actual)
    }

    @Test
    fun testObserverEmitsMultipleTimes() {
        val expected = "Testing observer"
        val appContext = ApplicationProvider.getApplicationContext<Context>()
        val store = Store(appContext)
        val firstLatchDown = CountDownLatch(1)
        val secondLatchDown = CountDownLatch(2)
        val actual = mutableListOf<String?>()

        GlobalScope.launch {
            val observer = store.observe(TestKeys.memoryString)
            observer
                .timeout(6, TimeUnit.SECONDS)
                .subscribe({
                    firstLatchDown.countDown()
                    actual.add(it.toNullable())
                    secondLatchDown.countDown()
                }, {
                    firstLatchDown.countDown()
                    repeat(secondLatchDown.count.toInt()) {
                        secondLatchDown.countDown()
                    }
                })
        }

        firstLatchDown.await()
        store.set(TestKeys.memoryString, expected)
        secondLatchDown.await()

        Assert.assertNull(actual[0])
        assertEquals(expected, actual[1])
    }

    @Test
    fun testDestroy() {
        val expected = "Testing destroy"
        val appContext = ApplicationProvider.getApplicationContext<Context>()
        val stringKey = SharedPrefsStoreKey(id = "string_key", uuid = "id", clazz = String::class.java)
        val store = Store(appContext)
        store.set(stringKey, expected)

        store.destroy()

        Assert.assertNull(store.get(stringKey))
        Assert.assertFalse(store.has(stringKey))

        store
            .observe(stringKey)
            .test()
            .assertError { it is StoreException.StoreDestroyed }

        // Assert that store drops any set operations on the floor after a destroy
        store.set(stringKey, expected).run {
            Assert.assertNull(store.get(stringKey))
        }
    }

    @Test
    fun testRemoveAll() {
        val expected = "Testing remove all"
        val appContext = ApplicationProvider.getApplicationContext<Context>()
        val stringKey = SharedPrefsStoreKey(id = "string_key", uuid = "id", clazz = String::class.java)
        val store = Store(appContext)
        store.set(stringKey, expected)

        store.removeAll(StoreKind.values())

        Assert.assertNull(store.get(stringKey))
        Assert.assertFalse(store.has(stringKey))

        store
            .observe(stringKey)
            .test()
            .assertValue(null.toOptional())

        // Assert that store drops any set operations on the floor after a destroy
        store.set(stringKey, expected)

        assertEquals(expected, store.get(stringKey))
        Assert.assertTrue(store.has(stringKey))
        store.observe(stringKey)
            .test()
            .assertValue(expected.toOptional())
    }

    @Test
    fun encryptStringStoreKeyValue() {
        val expectedText = "Bitcoin + Ethereum"
        val store = Store(ApplicationProvider.getApplicationContext<Context>())

        store.set(TestKeys.encryptedString, expectedText)

        val actual = store.get(TestKeys.encryptedString)

        assertEquals(expectedText, actual)
    }

    @Test
    fun encryptComplexObjectStoreKeyValue() {
        val expected = MockComplexObject(name = "hish", age = 37, wallets = listOf("1234", "2345"))
        val store = Store(ApplicationProvider.getApplicationContext<Context>())

        store.set(TestKeys.encryptedComplexObject, expected)

        val actual = store.get(TestKeys.encryptedComplexObject)

        if (actual == null) {
            Assert.fail("Unable to get encrypted complex object")
            return
        }

        assertEquals(expected.name, actual.name)
        assertEquals(expected.age, actual.age)
        assertEquals(expected.wallets, actual.wallets)
    }

    @Test
    fun encryptArrayStoreKeyValue() {
        val expected = arrayOf("Bitcoin", "Ethereum")
        val store = Store(ApplicationProvider.getApplicationContext<Context>())

        store.set(TestKeys.encryptedArray, expected)

        val actual = store.get(TestKeys.encryptedArray)

        assertArrayEquals(expected, actual)
    }

    @Test
    fun encryptComplexObjectArrayStoreKeyValue() {
        val expected = arrayOf(
            MockComplexObject(name = "hish", age = 37, wallets = listOf("1234", "2345")),
            MockComplexObject(name = "aya", age = 3, wallets = listOf("333"))
        )

        val store = Store(ApplicationProvider.getApplicationContext<Context>())

        store.set(TestKeys.encryptedComplexObjectArray, expected)

        val actual = store.get(TestKeys.encryptedComplexObjectArray)

        assertArrayEquals(expected, actual)
    }

    @Test
    fun bigIntegerBigDecimalUrlAdapterValidation() {
        val expected = MockObjectForDefaultAdapters(
            id = BigInteger.TEN,
            gas = null,
            amount = BigDecimal(23809302302930),
            fee = null,
            imageURL = null,
            avatarImage = URL("https://www.example.com")
        )

        val store = Store(ApplicationProvider.getApplicationContext<Context>())

        store.set(TestKeys.adaptersKey, expected)

        val actual = store.get(TestKeys.adaptersKey)

        if (actual == null) {
            Assert.fail("Cannot be null")
            return
        }

        assertEquals(expected.id, actual.id)
        assertEquals(expected.gas, actual.gas)
        assertEquals(expected.amount, actual.amount)
        assertEquals(expected.fee, actual.fee)
        assertEquals(expected.imageURL, actual.imageURL)
        assertEquals(expected.avatarImage, actual.avatarImage)
    }

    @Test
    fun testStoreKeysEqual() {
        val newAdaptersKey = SharedPrefsStoreKey(id = "adaptersKey", clazz = MockObjectForDefaultAdapters::class.java)
        assertEquals(TestKeys.adaptersKey, newAdaptersKey)

        val newAdaptersMemoryKey = MemoryStoreKey(id = "adaptersKey", clazz = MockObjectForDefaultAdapters::class.java)
        assertNotEquals(newAdaptersMemoryKey, TestKeys.adaptersKey)
    }

    @Test
    fun testMemoryStoreKeyRemove() {
        val store = Store(ApplicationProvider.getApplicationContext<Context>())
        val memoryKey = MemoryStoreKey(id = "memoryStringKey", clazz = String::class.java)

        store.set(memoryKey, "test")
        store.set(memoryKey, null)

        val result = store.get(memoryKey)
        assertNull(result)
    }
}

object TestKeys {
        val activeUser = SharedPrefsStoreKey(id = "computedKeyX", clazz = String::class.java)

        fun computedKey(uuid: String): SharedPrefsStoreKey<String> {
            return SharedPrefsStoreKey(id = "computedKey", uuid = uuid, clazz = String::class.java)
        }

        val memoryBoolean = MemoryStoreKey(id = "memory_boolean", clazz = Boolean::class.java)

        val memoryInt = MemoryStoreKey(id = "memory_int", clazz = Int::class.java)

        val memoryString = MemoryStoreKey(id = "memory_string", clazz = String::class.java)

        val encryptedString = EncryptedSharedPrefsStoreKey(
            id = "encryptedString",
            clazz = String::class.java
        )

        val encryptedComplexObject = EncryptedSharedPrefsStoreKey(
            id = "encrypted_complex_object",
            clazz = MockComplexObject::class.java
        )

        val encryptedArray = EncryptedSharedPrefsStoreKey(id = "encrypted_array", clazz = Array<String>::class.java)

        val encryptedComplexObjectArray = EncryptedSharedPrefsStoreKey(
            id = "encrypted_complex_object_array",
            clazz = Array<MockComplexObject>::class.java
        )

        var adaptersKey = SharedPrefsStoreKey(id = "adaptersKey", clazz = MockObjectForDefaultAdapters::class.java)
}

data class MockComplexObject(val name: String, val age: Int, val wallets: List<String>) {
    override fun equals(other: Any?): Boolean {
        val obj2 = other as? MockComplexObject ?: return false

        return obj2.age == age && obj2.name == name && obj2.wallets == wallets
    }
}

data class MockObjectForDefaultAdapters(
    val id: BigInteger,
    val gas: BigInteger?,
    val amount: BigDecimal,
    val fee: BigDecimal?,
    val imageURL: URL?,
    val avatarImage: URL
)
