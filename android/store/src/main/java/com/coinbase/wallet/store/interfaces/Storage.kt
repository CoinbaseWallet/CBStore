 package com.coinbase.wallet.store.interfaces

import com.coinbase.wallet.store.models.StoreKey

internal interface Storage {
    /**
     * Store value for key
     *
     * @param key Key used to store value
     * @param value Value to be stored. If nil is passed, the entry will be removed.
     */
    fun <T> set(key: StoreKey<T>, value: T?)

    /**
     * Get value by key
     *
     * @param key Key to use to get value
     * @param clazz Value class type
     *
     * @return The stored value if available. Otherwise, nil
     */
    fun <T> get(key: StoreKey<T>): T?

    /**
     * Delete all keys in storage
     */
    fun destroy()
}
