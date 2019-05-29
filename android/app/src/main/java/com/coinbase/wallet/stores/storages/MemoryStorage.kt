package com.coinbase.wallet.stores.storages

import com.coinbase.wallet.stores.interfaces.Storage
import com.coinbase.wallet.stores.models.StoreKey
import java.util.concurrent.ConcurrentHashMap

class MemoryStorage : Storage {
    private val storage = ConcurrentHashMap<String, Any?>()

    override fun <T> set(key: StoreKey<T>, value: T?) {
        if (value == null) {
            storage.remove(key.name)
        }

        storage[key.name] = value
    }

    override fun <T> get(key: StoreKey<T>): T? {
        val value = storage[key.name]

        if (key.clazz.isInstance(value)) {
            return key.clazz.cast(value)
        }

        return null
    }
}