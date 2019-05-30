package com.coinbase.wallet.store.interfaces

import com.coinbase.wallet.store.models.Optional
import com.coinbase.wallet.store.models.StoreKey
import io.reactivex.Observable

/**
 * Store operation interface. Generally used to stub out Stores in unit tests
 */
interface StoreInterface {
    /**
     * Set value for key
     *
     * @param key Key for store value
     * @param value: Value to be stored
     */
    fun <T> set(key: StoreKey<T>, value: T?)

    /**
     * Get value for key
     *
     * @param key Key for store value
     *
     * @return Value if exists or nil
     */
    fun <T> get(key: StoreKey<T>): T?

    /**
     * Determine whether a value exists
     *
     * @param key Key for store value
     *
     * @returns: True if value exists
     */
    fun <T> has(key: StoreKey<T>): Boolean

    /**
     * Add observer for store changes
     *
     * @param key Key to start observing for changes
     *
     * @return Observer
     */
    fun <T> observe(key: StoreKey<T>): Observable<Optional<T>>
}
