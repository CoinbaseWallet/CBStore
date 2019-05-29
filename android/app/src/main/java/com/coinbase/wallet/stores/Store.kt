package com.coinbase.wallet.stores

import android.content.Context
import com.coinbase.wallet.stores.exceptions.StoreException
import com.coinbase.wallet.stores.interfaces.Storage
import com.coinbase.wallet.stores.interfaces.StoreInterface
import com.coinbase.wallet.stores.models.Optional
import com.coinbase.wallet.stores.models.StoreKey
import com.coinbase.wallet.stores.models.StoreKind
import com.coinbase.wallet.stores.storages.EncryptedSharedPreferencesStorage
import com.coinbase.wallet.stores.storages.MemoryStorage
import com.coinbase.wallet.stores.storages.SharedPreferencesStorage
import io.reactivex.Observable
import io.reactivex.subjects.BehaviorSubject
import java.util.concurrent.locks.ReentrantReadWriteLock
import kotlin.concurrent.read
import kotlin.concurrent.write

class Store(context: Context) : StoreInterface {
    private val prefsStorage = SharedPreferencesStorage(context)
    private val encryptedPrefsStorage = EncryptedSharedPreferencesStorage(context)
    private val memoryStorage = MemoryStorage()
    private val changeObservers = mutableMapOf<String, Any>()
    private val changeObserversLock = ReentrantReadWriteLock()

    override fun <T> set(key: StoreKey<T>, value: T?) {
        storageForKey(key).set(key, value)
    }

    override fun <T> get(key: StoreKey<T>): T? {
        return storageForKey(key).get(key)
    }

    override fun <T> has(key: StoreKey<T>): Boolean {
        return get(key) != null
    }

    override fun <T> observe(key: StoreKey<T>): Observable<Optional<T>> {
        return observer(key).hide()
    }

    // Private helpers

    private fun <T> storageForKey(key: StoreKey<T>): Storage {
        return when (key.kind) {
            StoreKind.SHARED_PREFERENCES -> prefsStorage
            StoreKind.ENCRYPTED_SHARED_PREFERENCES -> encryptedPrefsStorage
            StoreKind.MEMORY -> memoryStorage
        }
    }

    @Suppress("UNCHECKED_CAST")
    private fun <T> observer(key: StoreKey<T>): BehaviorSubject<Optional<T>> {
        // Check if we have an observer registered in concurrent mode
        var currentObserver: BehaviorSubject<Optional<T>>? = null
        changeObserversLock.read {
            currentObserver = changeObservers[key.name] as? BehaviorSubject<Optional<T>>
        }

        val anObserver = currentObserver
        if (anObserver != null) {
            return anObserver
        }

        // If we can't find an observer, enter serial mode and check or create new observer
        var newObserver: BehaviorSubject<Optional<T>>? = null
        val value = get(key)

        changeObserversLock.write {
            changeObservers[key.name]?.let { return it as BehaviorSubject<Optional<T>> }

            val observer = BehaviorSubject.create<Optional<T>>()
            changeObservers[key.name] = observer
            newObserver = observer

            observer.onNext(Optional(value))
        }

        return newObserver ?: throw StoreException.UnableToCreateObserver()
    }
}