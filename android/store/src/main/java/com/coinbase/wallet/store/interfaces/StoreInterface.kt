package com.coinbase.wallet.store.interfaces

import com.coinbase.wallet.store.models.StoreKey
import com.coinbase.wallet.store.models.StoreKind
import com.coinbase.wallet.core.util.Optional
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
    fun <T : Any> set(key: StoreKey<T>, value: T?)

    /**
     * Get value for key
     *
     * @param key Key for store value
     *
     * @return Value if exists or nil
     */
    fun <T : Any> get(key: StoreKey<T>): T?

    /**
     * Determine whether a value exists
     *
     * @param key Key for store value
     *
     * @returns: True if value exists
     */
    fun <T : Any> has(key: StoreKey<T>): Boolean

    /**
     * Add observer for store changes
     *
     * @param key Key to start observing for changes
     *
     * @return Observer
     */
    fun <T : Any> observe(key: StoreKey<T>): Observable<Optional<T>>

    /**
     * Destroy the store. This will make the current store unusable,
     * any in-flight reads/writes will block and then fail
     */
    fun destroy()

    /**
     * Delete all entries for given store kinds.
     *
     * @param kinds: Array of [com.coinbase.wallet.store.models.StoreKind] to clear out
     */
    fun removeAll(kinds: Array<StoreKind>)
}
