package com.coinbase.wallet.store.storages

import com.coinbase.wallet.store.interfaces.Storage
import com.coinbase.wallet.store.models.StoreKey
import java.util.concurrent.ConcurrentHashMap

internal class MemoryStorage : Storage {
    private val storage = ConcurrentHashMap<String, Any?>()

    override fun <T> set(key: StoreKey<T>, value: T?) {
        if (value == null) {
            storage.remove(key.name)
            return
        }

        storage[key.name] = value
    }

    @Suppress("UNCHECKED_CAST")
    override fun <T> get(key: StoreKey<T>): T? {
        return storage[key.name] as? T
    }

    override fun destroy() {
        storage.clear()
    }
}
